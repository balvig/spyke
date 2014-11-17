# Spyke

Spyke allows you to interact with remote REST services in an ActiveRecord-like manner.

It basically ~~rips off~~ takes inspiration :innocent: from [Her](https://github.com/remiprev/her), a gem which we sadly had to abandon as it showed significant performance problems and maintenance seemed to had gone stale. 

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
  end
end

Spyke::Config.connection = Faraday.new(url: 'http://api.com') do |c|
  c.use JSONParser
  c.use Faraday::Adapter::NetHttp
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

## Contributing

If possible please take a look at the tests marked "wishlisted"! 
These are features/fixes we want to implement but haven't gotten around to doing yet :)
