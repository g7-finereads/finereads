# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'lazyrecord'
require 'http'
require_relative 'books'

class Searchbook
  def initialize(query)
    @query = query
    @totalitems = nil
    @base_url = "https://www.googleapis.com/books/v1/volumes?q=#{query}"
    @max = 'maxResults=8'
  end

  def search_with_parameter(parameter = nil, index = 0)
    parameter = parameter == "All" ? '' : "+#{parameter}:#{@query}"
    base = "#{@base_url}#{parameter}&startIndex=#{index}&#{@max}"
    result = HTTP.headers(accept: 'application/json').get(base).parse
    [result, result['totalItems']]
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
    img.nil? ? default_img : img
  end

  def return_any(element, book)
    query = book['volumeInfo'][element]
    query.nil? ? "Unknown #{element}" : query
  end

  def return_all(book)
    array = []
    array << return_images(book) << return_any('title', book)
    array << return_any('subtitle', book) << return_any('authors', book)
    array << return_any('description', book) << return_any('language', book)
    array << return_any('categories', book)
    array
  end

  def info_books
    final = {}
    return nil if @items.nil?
    @items.each { |book| final[book['id']] = return_all(book) }
    final
  end
end

helpers do
  set :static_cache_control, [:public, max_age: 1]

  def findbooks_with_parameter(parameter, page)
    book = Searchbook.new(params['q'].gsub(/\s+/, '%20'))
    array = book.search_with_parameter(parameter, page)
    array_items = array[0]['items']
    deploy = DeployBooks.new(array_items)
    @arrayitems = deploy.info_books.to_a
    [@arrayitems, array[1]]
  end

  def num_items(parameter, page)
    book = Searchbook.new(params['q'].gsub(/\s+/, '%20'))
    array = book.search_with_parameter(parameter, page)
    array['totalItems'].to_i
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

get '/search' do
  unless params.empty?
    page = params['page'].to_i
    index = page == 1 ? 0 : page * 8
    @search_by = params['search_by']
    findbooks = findbooks_with_parameter(@search_by, index)
    unless params['q'].nil? || params['q'] == ''
      @arrayitems = findbooks[0]
    end
    @totalitems = findbooks[1]
  end
  erb :search_page,locals:{page: page}

end

get '/my_books' do
  @books = params['add'].nil? ? Book.all : savebook(params['add'])
  @status = params['status'] unless params['status'].nil?
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

get '/error?' do
  erb '/books/error-book'.to_sym
end

post '/action' do
  p params
  book = Book.find(params['id'])
  book.status = params['status']
  book.notes = params['notes']
  book.save
  redirect to('/my_books')
end
