require 'rubygems'
require 'highline/import'
require 'httparty'
require 'yaml'
require 'term/ansicolor'
require 'pstore'
require 'date'

include Term::ANSIColor

require 'twitterer'
require 'tweet'

if ARGV[0] == 'history'
  no_of_tweets = ARGV[1]
  tweets = Tweet.new
  tweets.history(no_of_tweets)
elsif ARGV[0] == 'friends'
  tweets = Tweet.new
  tweets.friends
else
  puts "Usage: ruby twitpow.rb [options]. \noptions: friends, history [no of tweets]"
end

