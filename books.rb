# frozen_string_literal: true

require 'lazyrecord'
require 'http'

class Book < LazyRecord
  attr_accessor :title, :authors, :id, :description, :image, :date, :status, :owned, :notes
  def initialize(title:, authors:, id:, description:, image:)
    @title = title
    @authors = authors
    @id = id
    @description = description
    @image = image
    @date = Time.now.strftime('%F')
    @notes = ''
    @status = 'Not read'
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

  def add_book(id)
    query = "https://www.googleapis.com/books/v1/volumes/#{id}"
    response = HTTP.get(query).parse
    title = return_any('title', response)
    authors = return_any('authors', response)
    description = return_any('description', response)
    image = return_images(response)
    Book.create(title: title, authors: authors, id: id, description: description, image: image)
  end
end
