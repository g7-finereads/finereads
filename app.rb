# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'lazyrecord'
require 'http'

class Searchbook
  def initialize(query)
    @query = query
    @base_url = "https://www.googleapis.com/books/v1/volumes?q=#{query}"
  end

  def request
    HTTP.headers(accept: 'application/json')
  end

  def search
    result = request.get(@base_url)
    books = result
    books.parse
   end
end

class DeployBooks
  def initialize(array)
    @items = array
  end

  def return_images(book)
    img = book['volumeInfo']['imageLinks']['thumbnail']
    img.nil? ? '/public/images/image-default.png' : img
  end

  def return_any(element, book)
    query = book['volumeInfo'][element]
    query.nil? ? "Unknown #{element}" : query
  end

  def return_all(book)
    array = []
    array.push(return_images(book))
    array.push(return_any('title', book))
    array.push(return_any('subtitle', book))
    array.push(return_any('authors', book))
    array.push(return_any('description', book))
    array.push(return_any('pageCount', book))
    array.push(return_any('categories', book))
    array
  end

  def info_books
    final = {}
    @items.each_with_index do |book, index|
      final[index + 1] = return_all(book)
    end
    final
  end
end
class Deployment
  def initialize(array_final)
    @array = array_final
  end
end

helpers do
  set :static_cache_control, [:public, max_age: 1]
end

get '/:page?' do
  cache_control :public, max_age: 1
  if params['page'].nil?
    erb :index
  else
    erb params['page'].to_sym
  end
end

get '/' do
  erb :index
end

get '/search' do
  erb :search_page
end

get '/books' do
  test = Searchbook.new(params['q'])
  array = test.search['items']
  deploy = DeployBooks.new(array)
  @arrayitems = deploy.info_books
  @arrayitems = @arrayitems.to_a
  erb :search_page
end
