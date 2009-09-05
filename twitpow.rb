require 'rubygems'
require 'highline/import'
require 'httparty'
require 'yaml'
require 'term/ansicolor'
require 'pstore'
require 'time'

include Term::ANSIColor

require 'twitterer'
require 'tweet'

if ARGV[0] == 'history'
  tweets = Tweet.new
  no_of_tweets = nil
  if ARGV[1] == 'search'
    query = ARGV[2]
  else  
    no_of_tweets = ARGV[1]
  end
  tweets.history(no_of_tweets, query)
elsif ARGV[0] == 'friends'
  tweets = Tweet.new
  tweets.friends
elsif ARGV[0] == 'mentions'
  tweets = Tweet.new
  tweets.mentions
else
  puts "\nUsage: \nruby twitpow.rb [options] \n\noptions: \n- friends \n- mentions \n- history [no of tweets] \n- history search [query]\n\n"
end

