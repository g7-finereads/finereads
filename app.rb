# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'lazyrecord'
require 'http'

helpers do
end

set :static_cache_control, [:public, max_age: 1]

# get "/:page?" do
#   cache_control :public, max_age: 1
#   if params["page"].nil?
#     erb :index, layout: :layout
#   else
#     erb params["page"].to_sym, layout: :layout
#   end
# end

get '/' do
  erb :index
end

get '/search' do
  erb :search
end

# get '/search2' do
#   erb '/books/book_card'.to_sym
# end

get '/list-books' do
  erb :list_books
end
