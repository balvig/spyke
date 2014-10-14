# Set up dummy api
Spike::Request.connection = Faraday.new(url: 'http://sushi.com') do |faraday|
  faraday.response  :json
  faraday.adapter   Faraday.default_adapter  # make requests with Net::HTTP
end
