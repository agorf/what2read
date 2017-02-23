require 'fileutils'
require 'json'
require 'net/http'
require 'open-uri'
require 'sequel'
require 'what2read/database'
require 'what2read/author'
require 'what2read/shelf'

module What2Read
  class Book < Sequel::Model
    MIN_RATINGS = ENV.fetch('MIN_RATINGS', 100).to_i

    many_to_many :authors
    many_to_many :shelves

    def self.parse_and_create(review_node)
      book_node = review_node.at('book')

      isbn = at(book_node, 'isbn13') || at(book_node, 'isbn')
      isbn = isbn.scan(/\d+/).join if isbn

      book         = Book.new
      book.isbn    = isbn
      book.title   = at(book_node, 'title')
      book.link    = at(book_node, 'link')
      book.pages   = at(book_node, 'num_pages', Integer)
      book.rating  = at(book_node, 'average_rating', Float)
      book.ratings = at(book_node, 'ratings_count', Integer)

      book.save # raises on failure

      book_node.css('authors author').each do |author_node|
        name = at(author_node, 'name')

        unless author = Author[name: name]
          author = Author.new
          author.name = name
          author.link = at(author_node, 'link')
        end

        book.add_author(author)
      end

      review_node.css('shelves shelf').each do |shelf_node|
        name = shelf_node['name']

        unless shelf = Shelf[name: name]
          shelf = Shelf.new
          shelf.name = name
        end

        book.add_shelf(shelf)
      end

      book.download_cover(book_node)

      book
    end

    def self.at(node, selector, klass = String)
      text = node.at(selector).text.strip
      return if text.length == 0
      method(klass.name.to_sym).call(text)
    end

    def download_cover(book_node)
      public_cover_path = File.join('public', cover_path)

      return if File.exist?(public_cover_path)

      cover_url = goodreads_cover_url(book_node) || openlibrary_cover_url ||
        google_cover_url || placeholder_cover_url

      FileUtils.mkdir_p(File.dirname(public_cover_path))

      File.open(public_cover_path, 'w') do |f|
        IO.copy_stream(open(cover_url), f)
      end
    end

    def cover_path
      @cover_path ||= File.join('covers', Digest::MD5.hexdigest(title))
    end

    def update_score!
      return if ratings < MIN_RATINGS

      # Bayesian estimates; http://stackoverflow.com/a/2134629
      self.score = ((rating * ratings + average_rating * MIN_RATINGS) /
       (ratings + MIN_RATINGS).to_f).round(2)

      save
    end

    private

    def at(*args)
      self.class.at(*args) # delegate
    end

    def average_rating
      @average_rating ||= self.class.avg(:rating)
    end

    def goodreads_cover_url(book_node)
      url = at(book_node, 'small_image_url')
      return if url =~ /\bnophoto\b/
      url
    end

    def google_cover_url
      return if isbn.nil?
      data = open("https://www.googleapis.com/books/v1/volumes?q=isbn:#{isbn}").read
      json = JSON.parse(data)
      item = json.fetch('items', [])[0]
      return if item.nil?
      item.fetch('volumeInfo', {}).fetch('imageLinks', {})['smallThumbnail']
    end

    def openlibrary_cover_url
      return if isbn.nil?
      uri = URI("http://covers.openlibrary.org/b/isbn/#{isbn}-S.jpg?default=false")
      http = Net::HTTP.new(uri.host, uri.port)
      response = http.head(uri.request_uri)
      return if response.code.to_i == 404
      uri.to_s
    end

    def placeholder_cover_url
      'http://s.gr-assets.com/assets/nophoto/book/50x75.png'
    end
  end
end
