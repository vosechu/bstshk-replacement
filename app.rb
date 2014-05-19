require 'sinatra'
require "sinatra/reloader" if development?
require 'faraday'
require 'json'

set :client_key, ENV.fetch('TWITTER_KEY')
set :client_secret, ENV.fetch('TWITTER_SECRET')
# Build this via `echo -n "client_key:client_secret" | base64`
set :encoded_key, ENV.fetch('TWITTER_ENCODED')

get '/' do
  conn = Faraday.new(:url => 'https://api.twitter.com') do |c|
    c.use Faraday::Response::Logger
    c.use Faraday::Adapter::NetHttp
  end

  # Post to oauth2/token to acquire our personal bearer token which is good for the next
  # couple of minutes.
  response = conn.post do |req|
    req.url '/oauth2/token/'
    req.headers['Authorization'] = "Basic #{settings.encoded_key}"
    req.headers['Content-Type'] = 'application/x-www-form-urlencoded;charset=UTF-8'
    req.headers['User-Agent'] = 'bstshk v0.0.1'
    req.body = "grant_type=client_credentials"
  end
  access_token = JSON.parse(response.body)['access_token']

  conn = Faraday.new(:url => 'https://api.twitter.com') do |c|
    c.use Faraday::Response::Logger
    c.use Faraday::Adapter::NetHttp
  end

  # Send a get to the user_timeline page and just output the json directly
  response = conn.get do |req|
    url = "/1.1/statuses/user_timeline.json?screen_name=#{params[:screen_name] || "best_of_mlkshk"}&count=50&trim_user=1&exclude_replies=1&include_entities=1"
    url += "&max_id=#{params[:max_id]}" if params[:max_id]
    req.url url
    req.headers['User-Agent'] = 'bstshk v0.0.2'
    req.headers['Authorization'] = "Bearer #{access_token}"
  end

  # Output the json feed directly or through json-p
  if params[:callback]
    content_type :js
    return "#{params[:callback]}(#{response.body})"
  else
    content_type :json
    return response.body
  end
end