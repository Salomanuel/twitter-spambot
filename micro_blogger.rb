require 'jumpstart_auth'

class MicroBlogger
	attr_reader :client

	def initialize
		puts "Initializing MicroBlogger"
		@client = JumpstartAuth.twitter			#OAuth AUTHENTICATION
		puts "Welcome to the JSL Twitter Client!"
		run
	end

	def rate
		require 'klout'
		Klout.api_key = 'xu9ztgnacmjx3bu82warbr3h'
		friends
		#screen_names = @friends.collect { |friend| friend.screen_name }
		@friends.each do |friend|
			identity = Klout::Identity.find_by_screen_name(friend.screen_name)
			puts "#{friend.screen_name}\trating: #{Klout::User.new(identity.id).score.score}"
		end
	end

	def shorten(original_url)
		require 'bitly'
		puts "\n *** shortening this URL: #{original_url} ***"
		Bitly.use_api_version_3
		bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
		short_url = bitly.shorten(original_url).short_url
		puts "...\ndone: #{short_url}"
	end

	def follower_names #used by spam my followers
		@follower_names = @client.followers.collect do |follower|
			@client.user(follower).screen_name 
		end
		return @follower_names
	end

	def friends #used by last tweet
		@friends = @client.friends.collect { |f| @client.user(f) }
		@friends.sort_by!{ |j| j.screen_name.downcase }
	end

	def tweet(message)
		if message.length > 139
			puts "tweet is too long, press W for whatever, R for rewriting it and E to exit"
			answer = gets.chomp.downcase
			case anwer
			when "w" then @client.update(message[0..139])
			#when "r" then tweet()
			when "e" then exit
			else tweet(message)
			end
		else
			@client.update(message)
		end
	end

	def spam_my_followers(message)
		follower_names
		@follower_names.each do |follower|
			direct_message(follower, message)
		end
	end

	def direct_message(target, message)
		puts "trying to send #{target} this direct message:"
		puts message
		message = "d @#{target} #{message}"
		follower_names
		if @follower_names.include?(target)
			tweet(message)
		else
			puts "you can only send messages to people who follow you"
		end
	end

	def everyones_last_tweet
		puts "\nloading the latest tweets of your friends:\n"
		friends
		@friends.each do |friend|
			time = friend.status.created_at.strftime("%A, %b %d")
			puts "\n\t#{friend.screen_name} wrote: \n #{friend.status.text} \n\t #{time}"
		end
		return ""
	end


	def run
		parts = ""
		while parts[0] != "q"
			puts "\npress Q to exit, T to tweet, DM to send a message" 
			puts "LAST to see everyone's last post, SPAM to spam all your followers"
			puts "SHORT to shorten a URL, RATE to see your friends Klout ratings"
			parts   = gets.chomp.downcase.split(" ")
			case parts[0]
			when "q"  	then puts "Goodbye"
			when "t"  	then tweet(parts[1..-1].join(" "))
			when "dm" 	then direct_message(parts[1], parts[2..-1].join(" "))
			when "spam" then spam_my_followers(parts[1..-1].join(" "))
			when "last" then everyones_last_tweet
			when "short"then shorten(parts[1])
			when "rate" then rate
			else
				puts "what the hell does \"#{parts[0]}\" means"
			end
		end
	end
end

blogger = MicroBlogger.new
#puts blogger.everyones_last_tweet
#blogger.tweet("MicroBlogger Initialized")
#blogger.tweet("this tweet is way longer than the usual 140 characters. Let's see what will happen after I try to send it. I'm very curious about it. My bloody ear hurts because of this stupid otitis, I can't wait for it to finish")
#blogger.tweet("are you still working?")