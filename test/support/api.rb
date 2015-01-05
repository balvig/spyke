# Set up dummy api
class JSONParser < Faraday::Response::Middleware
  def parse(body)
    json = MultiJson.load(body, symbolize_keys: true)
    {
      data: json[:result],
      metadata: json[:metadata],
      errors: [json[:message]]
    }
  rescue MultiJson::ParseError => exception
    { errors: [exception.cause] }
  end
end

Spyke::Config.connection = Faraday.new(url: 'http://sushi.com') do |faraday|
  faraday.request   :json
  faraday.use       JSONParser
  faraday.adapter   Faraday.default_adapter
end
