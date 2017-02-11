require 'dotenv'
require 'erb'
require 'nokogiri'
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
    node.at('title').text
  end

  def truncated_title
    truncate(title, 50)
  end

  def authors
    node.css('authors author name').map(&:text)
  end

  def link
    node.at('link').text
  end

  def average_rating
    node.at('average_rating').text.to_f
  end

  def ratings_count
    node.at('ratings_count').text.to_i
  end

  def score
    return 0 if ratings_count < MIN_RATINGS

    # Bayesian estimates; http://stackoverflow.com/a/2134629
    (average_rating * ratings_count + $average_rating * MIN_RATINGS) /
      (ratings_count + MIN_RATINGS).to_f
  end

  # Order by score DESC, title ASC
  def <=>(book)
    if score == book.score
      return title <=> book.title
    end

    -(score <=> book.score)
  end

  def to_s
    '%.2f %.2f %7d %s %s %s' % [score, average_rating, ratings_count,
                                truncated_title, truncated_authors,
                                truncated_link]
  end

  private

  def truncate(str, length)
    str[0...length].ljust(length, '.')
  end

  def truncated_authors
    truncate(authors.join(', '), 30)
  end

  def truncated_link
    link[%r{.*/show/\d+}]
  end
end

consumer = OAuth::Consumer.new(GOODREADS_API_KEY, GOODREADS_API_SECRET,
                               site: 'http://www.goodreads.com')

access_token = OAuth::AccessToken.new(consumer, OAUTH_ACCESS_TOKEN,
                                      OAUTH_ACCESS_SECRET)

page = 1

books = []

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
