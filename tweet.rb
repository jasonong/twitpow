class Tweet
  def initialize
    @twitterrc = File.join(ENV['HOME'], '.twitter')
    @config = YAML.load(File.read(@twitterrc))
    @since_id = @config['last_recent_id']
    tweets = File.dirname(__FILE__) + '/tweets'
    @store = PStore.new(tweets)
    @username = @config['username']

    @timeline_options = {}
    @timeline_options[:since_id] =  3781379748#@since_id
    @timeline_options[:count] = 200
  end

  def friends
    @twitter = Twitter.new(@username)
    @timeline = @twitter.timeline(:friends, :query => @timeline_options)
    store
  end
  
  def store
    n = 0
    @timeline.each do |status|
      user = status['user']
      status_id = status['id']
      created_at = Time.parse(status['created_at']).strftime("%a %I:%M%P")
      @store.transaction do 
        string = "#{status_id.to_s.blue} #{created_at.to_s.blue} #{user['name'].green.bold} #{user['screen_name'].red}: #{status['text'].yellow}"
        @store[status_id] = string
        puts string
      end
      @config['last_recent_id'] = status_id if n == 0
      n += 1
    end
    File.open(@twitterrc, 'w'){|file| YAML.dump(@config, file) }
  end

  def history(no_of_tweets = 50)
    n = 1
    @store.transaction do 
      @store.roots.sort.each do |index|
        puts @store[index]
        break if n == no_of_tweets.to_i
        n += 1
      end
    end
  end
end
