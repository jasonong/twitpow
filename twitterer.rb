class Twitter
  include HTTParty
  base_uri 'twitter.com'
      
  def initialize(u)
    password = ask("Enter Password") {|q| q.echo = false}
    @auth = {:username => u, :password => password}
  end
        
  # which can be :friends, :user or :public
  # options[:query] can be things like since, since_id, count, etc.
  def timeline(which=:friends, options={})
    options.merge!({:basic_auth => @auth})
    self.class.get("/statuses/#{which}_timeline.json", options)
  end

  def mentions(options={})
    options.merge!({:basic_auth => @auth})
    self.class.get("/statuses/mentions.json", options)
  end
        
  def post(options)
    options.merge!({:basic_auth => @auth})
    self.class.post('/statuses/update.json', options)
  end

  def users(which=:show, options={})
    options.merge!({:basic_auth => @auth})
    self.class.get("/users/#{which}.json", options)
  end
end
