class Tweet
  def initialize
    @twitterrc = File.join(ENV['HOME'], '.twitter')
    @config = YAML.load(File.read(@twitterrc))
    tweets = File.dirname(__FILE__) + '/tweets'
    @store = PStore.new(tweets)
    @username = @config['username']
  end

  def post(text)
    Twitter.update(text)
  end

  def reply(reply_to_status_id)
    @store.transaction do
      colored_status = @store[reply_to_status_id.to_i].uncolored
      status = colored_status.uncolored
      screen_name = status.match(/[\s]?[\w]+:[\s]/)[0].gsub(':', '').strip
      text = "@#{screen_name} "
      message = ask("Reply to: #{colored_status}"){|q| q.echo = true}
      text += message
      if message.size > 0 && text.size <= 140
        post(text, reply_to_status_id)
        puts text
      else
        extra_chars = text.size - 140
        puts "I can haz no tweet longer than 140 chars! Overshot by #{extra_chars}..."
      end
    end
  rescue
    puts "I can get no status!"
  end

  def retweet(reply_to_status_id)
    @store.transaction do
      status = @store[reply_to_status_id.to_i].uncolored
      puts status
      screen_name = status.match(/[\s]?[\w]+:[\s]/)[0].gsub(':', '').strip
      message = status.match(/:[\s].[\w].+$/)[0].sub(': ', '')
      text = "RT @#{screen_name} #{message}"
      string_to_prepend = STDIN.gets
      text = "#{string_to_prepend.chomp} #{text}"
      if text.size <= 140
        post(text)
        puts text
      else
        extra_chars = text.size - 140
        puts "I can haz no tweet longer than 140 chars! Overshot by #{extra_chars} chars! Try again!"
        puts text
      end
    end
  rescue
    puts "I can get no status!"
  end

  def user(screen_name)
    @twitter = Twitter.new(@username)
    user = @twitter.users(:show, :query => {:screen_name => screen_name})
    user.each do |key, value|
      if key == 'status'
        time = Time.parse(value['created_at']).strftime("%a %I:%M%P")
        puts "#{key.cyan}: #{time.blue} #{value['text'].yellow}"
      else
        puts "#{key.cyan}: #{value.to_s.yellow}"
      end
    end
    puts "\n"
  end

  def timeline_options(since_id_type)
    @timeline_options = {}
    @timeline_options[:since_id] =  @config[since_id_type] if @config[since_id_type]
    @timeline_options[:count] = 200
  end

  def friends
    timeline_options('last_recent_id')
    @timeline = Twitter.home_timeline(@timeline_options)
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
      # time = Date.parse(status['created_at'])
      created_at = status['created_at'].strftime("%a %I:%M%P")
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
      @store.roots.sort{|a,b| b <=> a}.each do |index|
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
