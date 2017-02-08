require 'dotenv'
require 'nokogiri'
require 'oauth'
require 'uri'

Dotenv.load!

MIN_RATINGS          = ENV.fetch('MIN_RATINGS', 1000).to_i
BOOK_TITLE_WIDTH     = 50
GOODREADS_API_KEY    = ENV.fetch('GOODREADS_API_KEY')
GOODREADS_API_SECRET = ENV.fetch('GOODREADS_API_SECRET')
GOODREADS_USER_ID    = ENV.fetch('GOODREADS_USER_ID')
OAUTH_ACCESS_TOKEN   = ENV.fetch('OAUTH_ACCESS_TOKEN')
OAUTH_ACCESS_SECRET  = ENV.fetch('OAUTH_ACCESS_SECRET')

Book = Struct.new(:title, :link, :average_rating, :ratings_count) do
  def score
    return 0 if ratings_count < MIN_RATINGS

    # Bayesian estimates; http://stackoverflow.com/a/2134629
    (average_rating * ratings_count + $average_rating * MIN_RATINGS) /
      (ratings_count + MIN_RATINGS).to_f
  end

  # Order by score ASC, title DESC
  def <=>(book)
    if score == book.score
      return -(title <=> book.title)
    end

    score <=> book.score
  end

  def to_s
    '%.2f %7d %.2f %s %s' % [average_rating, ratings_count, score,
                             truncated_title, truncated_link]
  end

  def truncated_link
    link[%r{.*/show/\d+}]
  end

  def truncated_title
    title[0...BOOK_TITLE_WIDTH].ljust(BOOK_TITLE_WIDTH, '.')
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

  reviews = Nokogiri.XML(response.body).at('reviews')

  books.concat(
    reviews.css('review').map do |book|
      Book.new(
        book.at('title').text,
        book.at('link').text,
        book.at('average_rating').text.to_f,
        book.at('ratings_count').text.to_i,
      )
    end
  )

  break if books.size == reviews['total'].to_i

  page += 1
end

$average_rating = books.map(&:average_rating).reduce(:+) / books.size.to_f
books.sort!

books_len = books.length
rank_pad = books_len.to_s.length

books.each_with_index do |book, i|
  if book.score == 0
    print ' ' * rank_pad
  else
    print (books_len - i).to_s.rjust(rank_pad)
  end

  puts " #{book}"
end

puts
puts "#{books_len} book(s) to read"
