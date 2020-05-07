# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'lazyrecord'
require 'http'

helpers do
end

get '/' do
  erb :index
end

get '/search' do
  erb '/books/book_card'.to_sym
end
get '/list-books' do
  erb '/books/list_books'.to_sym
end
