# require 'sinatra'
# require "sinatra/reloader" if development?
# require 'oauth2'
# require 'json'

# get '/' do

#   client_key = "IPIG3eNaeq6pHD2PRrXoew"
#   client_secret = "IbPPlorQDflMbzmVGNKiY4NG4UJ0xUBjzAIpwFQROw"

#   # Exchange our oauth_token and oauth_token secret for the AccessToken instance.
#   # access_token = prepare_access_token("abcdefg", "hijklmnop")
#   # use the access token as an agent to get the home timeline
#   client = OAuth2::Client.new(client_key, client_secret,
#       { :site => "https://api.twitter.com",
#         :scheme => :header
#       })
#   client.auth_code.authorize_url(:redirect_uri => 'http://localhost:9292/oauth2/callback')
#   token = client.auth_code.get_token('authorization_code_value', :redirect_uri => 'http://localhost:8080/oauth2/callback', :headers => {'Authorization' => 'Basic some_password'})
#   response = token.get('/api/resource', :params => { 'query_foo' => 'bar' })
#   response.class.name
#   consumer.inspect
#   # response = access_token.request(:get, "https://api.twitter.com/1.1/statuses/home_timeline.json")
#   # response
#   # conn = Faraday.new(:url => 'https://api.github.com') do |c|
#   #   c.use Faraday::Response::Logger
#   #   c.use Faraday::Adapter::NetHttp
#   # end

#   # response = conn.get do |req|
#   #   req.url '/user'
#   #   req.headers['User-Agent'] = 'exercism v0.0.1.pre-alpha'
#   #   req.params['access_token'] = access_token
#   # end
#   # result = JSON.parse(response.body)
#   # [result['id'], result['login'], result['email']]
# end

# get '/oauth2/callback' do
#   p params
# end

# require 'sinatra'
# require "sinatra/reloader" if development?
# require 'twitter'

# Twitter.configure do |config|
#   config.consumer_key = "IPIG3eNaeq6pHD2PRrXoew"
#   config.consumer_secret = "IbPPlorQDflMbzmVGNKiY4NG4UJ0xUBjzAIpwFQROw"
#   config.oauth_token = "30216653-tArH0F1YanSm10wlYAdgIygcDdqtoCZH44VYjrZxc"
#   config.oauth_token_secret = "iz2wVKS8jLPn3svZVw073DSKRDgbKjTNyikBmlUw"
# end

# get '/' do
#   tweets = Twitter.user_timeline("best_of_mlkshk", count: 10, trim_user: 1, exclude_replies: 1, include_entities: 1)
#   tweets.to_json(:)
# end

require 'sinatra'
require "sinatra/reloader" if development?
require 'faraday'
require 'base64'
require 'json'

get '/' do
  conn = Faraday.new(:url => 'https://api.twitter.com') do |c|
    c.use Faraday::Response::Logger
    c.use Faraday::Adapter::NetHttp
  end

  client_key = ENV.fetch('TWITTER_KEY')
  client_secret = ENV.fetch('TWITTER_SECRET')
  encoded_key = ENV.fetch('TWITTER_ENCODED')

  response = conn.post do |req|
    req.url '/oauth2/token/'
    req.headers['Authorization'] = "Basic #{encoded_key}"
    req.headers['Content-Type'] = 'application/x-www-form-urlencoded;charset=UTF-8'
    req.headers['User-Agent'] = 'bstshk v0.0.1'
    req.body = "grant_type=client_credentials"
  end
  access_token = JSON.parse(response.body)['access_token']

  conn = Faraday.new(:url => 'https://api.twitter.com') do |c|
    c.use Faraday::Response::Logger
    c.use Faraday::Adapter::NetHttp
  end

  response = conn.get do |req|
    req.url '/1.1/statuses/user_timeline.json?screen_name=best_of_mlkshk&count=10&trim_user=1&exclude_replies=1&include_entities=1'
    req.headers['User-Agent'] = 'bstshk v0.0.1'
    req.headers['Authorization'] = "Bearer #{access_token}"
  end

  return response.body
end