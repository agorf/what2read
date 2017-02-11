require 'dotenv'
require 'erb'
require 'json'
require 'net/http'
require 'nokogiri'
require 'open-uri'
require 'oauth'
require 'uri'

Dotenv.load!

GOODREADS_API_KEY    = ENV.fetch('GOODREADS_API_KEY')
GOODREADS_API_SECRET = ENV.fetch('GOODREADS_API_SECRET')
GOODREADS_USER_ID    = ENV.fetch('GOODREADS_USER_ID')
OAUTH_ACCESS_TOKEN   = ENV.fetch('OAUTH_ACCESS_TOKEN')
OAUTH_ACCESS_SECRET  = ENV.fetch('OAUTH_ACCESS_SECRET')

class Book
  MIN_RATINGS = ENV.fetch('MIN_RATINGS', 1000).to_i

  attr_reader :node

  def initialize(node)
    @node = node
  end

  def title
    at('title')
  end

  def authors
    node.css('authors author name').map(&:text)
  end

  def link
    at('link')
  end

  def pages
    at('num_pages', Integer)
  end

  def average_rating
    at('average_rating', Float)
  end

  def ratings_count
    at('ratings_count', Integer)
  end

  def score
    return 0 if ratings_count < MIN_RATINGS

    # Bayesian estimates; http://stackoverflow.com/a/2134629
    ((average_rating * ratings_count + $average_rating * MIN_RATINGS) /
     (ratings_count + MIN_RATINGS).to_f).round(2)
  end

  def cover_url
    goodreads_image_url || openlibrary_image_url || google_image_url ||
      placeholder_image_url
  end

  # Order by score DESC, ratings DESC, title ASC
  def <=>(book)
    if score != book.score
      return -(score <=> book.score)
    end

    if ratings_count != book.ratings_count
      return -(ratings_count <=> book.ratings_count)
    end

    return title <=> book.title
  end

  private

  def isbn
    at('isbn13') || at('isbn')
  end

  def goodreads_image_url
    url = at('small_image_url')
    return if url =~ /\bnophoto\b/
    url
  end

  def openlibrary_image_url
    return if isbn.nil?
    uri = URI("http://covers.openlibrary.org/b/isbn/#{isbn}-S.jpg?default=false")
    http = Net::HTTP.new(uri.host, uri.port)
    response = http.head(uri.request_uri)
    return if response.code.to_i == 404
    uri.to_s
  end

  def google_image_url
    return if isbn.nil?
    data = open("https://www.googleapis.com/books/v1/volumes?q=isbn:#{isbn}").read
    json = JSON.parse(data)
    item = json.fetch('items', [])[0]
    return if item.nil?
    item.fetch('volumeInfo', {}).fetch('imageLinks', {})['smallThumbnail']
  end

  def placeholder_image_url
    'http://s.gr-assets.com/assets/nophoto/book/50x75.png'
  end

  def at(selector, klass = String)
    text = node.at(selector).text.strip
    return if text.length == 0
    method(klass.name.to_sym).call(text)
  end
end

consumer = OAuth::Consumer.new(GOODREADS_API_KEY, GOODREADS_API_SECRET,
                               site: 'http://www.goodreads.com')

access_token = OAuth::AccessToken.new(consumer, OAUTH_ACCESS_TOKEN,
                                      OAUTH_ACCESS_SECRET)

page = 1

books = []

$stderr.puts "Please wait; this may take a while..."

loop do
  query = URI.encode_www_form(
    v:        2,
    id:       GOODREADS_USER_ID,
    shelf:    'to-read',
    page:     page,
    per_page: 200,
    key:      GOODREADS_API_KEY,
  )
  response = access_token.get("/review/list.xml?#{query}")

  doc = Nokogiri.XML(response.body)

  books.concat(doc.css('book').map {|node| Book.new(node) })

  break if books.size == doc.at('reviews')['total'].to_i

  page += 1
end

$average_rating = books.map(&:average_rating).reduce(:+) / books.size.to_f
books.sort!

puts ERB.new(File.read('template.html.erb')).result(binding)
