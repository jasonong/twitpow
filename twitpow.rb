require 'rubygems'
require 'bundler/setup'

require 'highline/import'
require 'httparty'
require 'yaml'
require 'term/ansicolor'
require 'pstore'
require 'time'

include Term::ANSIColor

current_dir = File.dirname(__FILE__)
require "#{current_dir}/twitterer"
require "#{current_dir}/tweet"

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
elsif ARGV[0] == 'update'
  text = ARGV[1]
  if text && text.size > 0 && text.size <= 140
    tweets = Tweet.new
    tweets.post(text)
  else
    extra_chars = text.size - 140
    puts "Hey! You're writing an essay? Overshot by #{extra_chars} characters."
  end
elsif ARGV[0] == 'reply'
  status_id = ARGV[1]
  if status_id
    tweets = Tweet.new
    tweets.reply(status_id)
  end
elsif ARGV[0] == 'retweet'
  status_id = ARGV[1]
  if status_id
    tweets = Tweet.new
    tweets.retweet(status_id)
  end
elsif ARGV[0] == 'user'
  screen_name = ARGV[1]
  if screen_name
    tweets = Tweet.new
    tweets.user(screen_name)
  end
else
  puts """
Usage:
ruby twitpow.rb [options]

Options:
- friends
- mentions
- update [tweet]
- reply [status id]
- retweet [status id]
- history [no of tweets]
- history search [query]

"""
end

