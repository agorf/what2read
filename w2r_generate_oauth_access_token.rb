require 'dotenv'
require 'launchy'
require 'oauth'

Dotenv.load!

request_token = OAuth::Consumer.new(
  ENV.fetch('GOODREADS_API_KEY'),
  ENV.fetch('GOODREADS_API_SECRET'),
  site: 'http://www.goodreads.com'
).get_request_token

puts "Opening #{request_token.authorize_url}"
Launchy.open(request_token.authorize_url)

puts
puts 'Press ENTER after you have authorized the app'
gets

access_token = request_token.get_access_token
puts 'Place the following into your .env file:'
puts
puts "OAUTH_ACCESS_TOKEN=#{access_token.token}"
puts "OAUTH_ACCESS_SECRET=#{access_token.secret}"