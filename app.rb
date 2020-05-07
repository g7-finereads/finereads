require "sinatra"
require "sinatra/reloader"
require "lazyrecord"
require "http"

helpers do
end

get "/" do
  erb :index, layout: :layout
end
