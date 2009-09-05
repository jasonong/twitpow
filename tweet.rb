class Tweet
  def initialize
    @twitterrc = File.join(ENV['HOME'], '.twitter')
    @config = YAML.load(File.read(@twitterrc))
    tweets = File.dirname(__FILE__) + '/tweets'
    @store = PStore.new(tweets)
    @username = @config['username']
  end

  def post(text)
    @twitter = Twitter.new(@username)
    @twitter.post(text) 
  end

  def timeline_options(since_id_type)
    @timeline_options = {}
    @timeline_options[:since_id] =  @config[since_id_type]
    @timeline_options[:count] = 200
  end

  def friends
    @twitter = Twitter.new(@username)
    timeline_options('last_recent_id')
    @timeline = @twitter.timeline(:friends, :query => @timeline_options)
    store('last_recent_id')
  end

  def mentions
    @twitter = Twitter.new(@username)
    timeline_options('last_mention_id')
    @timeline = @twitter.mentions(:query => @timeline_options)
    store('last_mention_id')
  end
  
  def store(since_id_type)
    n = 0
    @timeline.each do |status|
      user = status['user']
      status_id = status['id']
      created_at = Time.parse(status['created_at']).strftime("%a %I:%M%P")
      @store.transaction do 
        string = "#{status_id.to_s.blue} #{created_at.to_s.blue} #{user['name'].cyan} #{user['screen_name'].red}: #{status['text'].yellow}"
        @store[status_id] = string
        puts string
      end
      @config[since_id_type] = status_id if n == 0
      n += 1
    end
    File.open(@twitterrc, 'w'){|file| YAML.dump(@config, file) }
  end

  def history(no_of_tweets = 50, query = nil)
    n = 1
    @store.transaction do 
      @store.roots.sort.each do |index|
        message = @store[index]
        if query
          puts message if message =~ /.+#{query}.+/
        else
          puts message
        end
        break if n == no_of_tweets.to_i && query == nil
        n += 1
      end
    end
  end
end
