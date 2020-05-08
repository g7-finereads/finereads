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
end

get '/:page?' do
  cache_control :public, max_age: 1
  what_page = params['page']
  case
  when what_page.nil?
    erb :index
  when what_page == 'books' || what_page == 'search'
    return erb :search_page if params['q'].empty?

    @arrayitems = findbooks
    erb :search_page
  when what_page == 'my_books'
    erb :my_books
  end
end
