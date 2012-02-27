Twitter.configure do |config|
  twitterrc = File.join(ENV['HOME'], '.twitter')
  twitpowrc = YAML.load(File.read(twitterrc))

  config.consumer_key = twitpowrc['consumer_key']
  config.consumer_secret = twitpowrc['consumer_secret']
  config.oauth_token = twitpowrc['oauth_token']
  config.oauth_token_secret = twitpowrc['oauth_token_secret']
end
