# frozen_string_literal: true

require 'lazyrecord'
require 'http'

class Book < LazyRecord
  attr_accessor :title, :subtitle, :authors, :id, :description, :image, :date, :status, :owned
  def initialize(title:, authors:, id:, description:, image:)
    @title = title
    @authors = authors
    @id = id
    @description = description
    @image = image
    @date_added = Time.now
    @notes = ''
    @status = 'not_read'
  end
end

class CreateBook < Book
  def add_book(id)
    query = "https://www.googleapis.com/books/v1/volumes/#{id}"
    response = HTTP.get(query).parse
    title = response['volumeInfo']['title']
    authors = response['volumeInfo']['author']
    description = response['volumeInfo']['description']
    image = response['volumeInfo']['imageLinks']['medium']
    Book.create(title: title, authors: authors, id: id, description: description, image: image).save
  end

  def change_status(_id, status)
    case status
    when 'want_to_read' then @status = 'want_to_read'
    when 'reading' then @status = 'reading'
    when 'read' then @status = 'read'
    end
  end

  def update_notes(id, notes)
    book = Book.find(id)
    @notes = notes
  end
end


