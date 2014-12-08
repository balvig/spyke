# Spyke

<p align="center">
  <img src="http://upload.wikimedia.org/wikipedia/en/thumb/2/21/Spyke.jpg/392px-Spyke.jpg" width="20%" />
  <br/>
  Interact with remote <strong>REST services</strong> in an <strong>ActiveRecord-like</strong> manner.
  <br /><br />
  <a href="http://badge.fury.io/rb/spyke"><img src="https://badge.fury.io/rb/spyke.svg" alt="Gem Version" height="18"></a>
  <a href="https://codeclimate.com/github/balvig/spyke"><img src="https://codeclimate.com/github/balvig/spyke/badges/gpa.svg" /></a>
  <a href='https://gemnasium.com/balvig/spyke'><img src="http://img.shields.io/gemnasium/balvig/spyke.svg" /></a>
  <a href="https://circleci.com/gh/balvig/spyke"><img src="https://circleci.com/gh/balvig/spyke.svg?style=svg" /></a>
</p>

---

Spyke basically ~~rips off~~ takes inspiration :innocent: from [Her](https://github.com/remiprev/her), a gem which we sadly had to abandon as it showed significant performance problems and maintenance seemed to had gone stale.

We therefore made Spyke which adds a few fixes/features that we needed for our projects:

- Fast handling of even large amounts of JSON
- Proper support for scopes
- Ability to define custom URIs for associations
- Googlable name! :)

## Configuration

Add this line to your application's Gemfile:

```ruby
gem 'spyke'
```

Like Her, Spyke uses Faraday to handle requests and expects it to return a hash in the following format:

```ruby
{ data: { id: 1, name: 'Bob' }, metadata: {} }
```

The simplest possible configuration that can work is something like this:

```ruby
# config/initializers/spyke.rb

class JSONParser < Faraday::Response::Middleware
  def parse(body)
    json = MultiJson.load(body, symbolize_keys: true)
    {
      data: json[:result],
      metadata: json[:metadata]
    }
  rescue MultiJson::ParseError => exception
    { error: exception.cause }
  end
end

Spyke::Config.connection = Faraday.new(url: 'http://api.com') do |c|
  c.request   :json
  c.use       JSONParser
  c.use       Faraday.default_adapter
end
```

## Usage

Adding a class and inheriting from `Spyke::Base` will allow you to interact with the remote service:

```ruby
class User < Spyke::Base
  has_many :posts
end

user = User.find(3) # => GET http://api.com/users/3
user.posts # => find embedded in user or GET http://api.com/users/3/posts
```

### Custom URIs

You can specify custom URIs on both the class and association level:

```ruby
class User < Spyke::Base
  uri '/v1/users/:id'

  has_one :image, uri: nil
  has_many :posts, uri: '/posts/for_user/:user_id'
end

class Post < Spyke::Base
end

user = User.find(3) # => GET http://api.com/v1/users/3
user.image # Will only use embedded JSON and never call out to api
user.posts # => GET http://api.com/posts/for_user/3
Post.find(4) # => GET http://api.com/posts/4
```

### Logging/Debugging

Spyke comes with Faraday middleware for Rails that will output helpful
ActiveRecord-like output to the main log as well as keep a record of
request/responses in  `/log/faraday.log`.

```bash
Started GET "/posts" for 127.0.0.1 at 2014-12-01 14:31:20 +0000
Processing by PostsController#index as HTML
  Parameters: {}
  GET http://api.com/posts [200]
```

To use it, simply add it to the stack of middleware:

```ruby
Spyke::Config.connection = Faraday.new(url: 'http://api.com') do |c|
  c.request   :json
  c.use       JSONParser
  c.use       Spyke::Middleware::RailsLogger if Rails.env.development?
  c.use       Faraday.default_adapter
end
```

## Contributing

If possible please take a look at the tests marked "wishlisted"!
These are features/fixes we want to implement but haven't gotten around to doing yet :)
