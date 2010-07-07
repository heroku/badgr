require 'sinatra'
require 'sinatra/redis'
require 'yajl'

enable :sessions

configure :production do
  set :redis, ENV["REDISTOGO_URL"]
end

helpers do
  def key(*args)
    args.join(":")
  end

  def tags_for(url)
    redis.smembers(key(url, :tags))
  end
end

get "/" do
  erb :index
end

get "/tags" do
  content_type :html
  erb :tags, :locals => { :tags => tags_for(params[:url]) }
end

put "/tags" do
  url = params[:url]
  (params[:tags] || "").split(" ").each do |tag|
    redis.sadd(key(url, :tags), tag)
  end
  redirect "/tags?url=" + escape(url)
end
