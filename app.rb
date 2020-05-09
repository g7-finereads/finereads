# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'lazyrecord'
require 'http'
require_relative 'books'

class Searchbook
  def initialize(query)
    @query = query
    @base_url = "https://www.googleapis.com/books/v1/volumes?q=#{query}"
  end

  def search
    result = HTTP.headers(accept: 'application/json').get(@base_url)
    books = result
    books.parse
   end
end

class DeployBooks
  def initialize(array)
    @items = array
  end

  def return_images(book)
    default_img = '/images/image-default.png'
    unless book['volumeInfo']['imageLinks'].nil?
      img = book['volumeInfo']['imageLinks']['thumbnail']
    end
    img = img.nil? ? default_img : img
  end

  def return_any(element, book)
    query = book['volumeInfo'][element]
    query.nil? ? "Unknown #{element}" : query
  end

  def return_all(book)
    array = []
    array << return_images(book) << return_any('title', book)
    array << return_any('subtitle', book) << return_any('authors', book)
    array << return_any('description', book) << return_any('pageCount', book)
    array << return_any('categories', book)
    array
  end

  def info_books
    final = {}
    @items.each { |book| final[book['id']] = return_all(book) }
    final
  end
end

helpers do
  set :static_cache_control, [:public, max_age: 1]
  def findbooks
    test = Searchbook.new(params['q'].gsub(/\s+/, '%20'))
    array = test.search['items']
    deploy = DeployBooks.new(array)
    @arrayitems = deploy.info_books.to_a
    @arrayitems.slice!(8..-1)
    @arrayitems
  end

  def savebook(id)
    CreateBook.new.add_book(id)
    Book.all
  end

  def deletebook(id)
    Book.delete(id)
  end
end

get '/' do
  erb :index
end
get '/books' do
  @arrayitems = findbooks unless params['q'].nil? || params['q'] == ''
  erb :search_page
end
get '/search' do
  erb :search_page
end
get '/my_books' do
  @books = if params['add'].nil?
             Book.all
           else
             savebook(params['add'])
           end
  erb :my_books
end

get '/action?' do
  @id = params['id']
  action = params['action']
  if action == 'edit'
    erb :book_edit
  else
    deletebook(@id)
    @books = Book.all
    erb :my_books
  end
end

get '/details?' do
  @id = params['id']
  erb :book_detail
end

post '/action' do
  erb :my_books
end
