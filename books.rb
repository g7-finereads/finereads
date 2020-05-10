# frozen_string_literal: true

require 'lazyrecord'
require 'http'

class Book < LazyRecord
  attr_accessor :title, :authors, :id, :description, :image, :date, :status, :owned, :notes
  def initialize(title:, authors:, id:, description:, image:, language:)
    @title = title
    @authors = authors
    @id = id
    @description = description
    @image = image
    @date = Time.now.strftime('%F')
    @notes = ''
    @status = 'Not read'
    @language = language
  end
end

class CreateBook
  def return_any(element, book)
    query = book['volumeInfo'][element]
    query.nil? ? "Unknown #{element}" : query
  end

  def return_images(book)
    default_img = '/images/image-default.png'
    unless book['volumeInfo']['imageLinks'].nil?
      img = book['volumeInfo']['imageLinks']['thumbnail']
    end
    img.nil? ? default_img : img
  end

  def saleability(book)
    saleability = book['saleInfo']['saleability']
    saleability == 'FOR_SALE'
  end

  def price(book)
    if saleability(book) == true
      price = book['saleInfo']['listPrice']['amount']
      price == 0 ? 'FREE' : price
    else
      price = 'NOT FOR SALE'
    end
  end

  def see_book(id)
    query = "https://www.googleapis.com/books/v1/volumes/#{id}"
    response = HTTP.get(query).parse
    title = return_any('title', response)
    authors = return_any('authors', response)
    description = return_any('description', response)
    language = return_any('language', response)
    image = return_images(response)
    price = price(response)
    hash = { id: id, title: title, authors: authors,
             description: description, image: image, price: price, language: language }
    hash
  end

  def add_book(id)
    query = "https://www.googleapis.com/books/v1/volumes/#{id}"
    response = HTTP.get(query).parse
    title = return_any('title', response)
    authors = return_any('authors', response)
    description = return_any('description', response)
    image = return_images(response)
    language = return_any('language', response)
    Book.create(title: title, authors: authors, id: id, description: description, image: image, language: language)
  end
end
