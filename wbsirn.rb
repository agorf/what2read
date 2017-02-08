#!/usr/bin/env ruby

require 'dotenv'
require 'nokogiri'
require 'oauth'

Dotenv.load

MIN_RATINGS = 100

Book = Struct.new(:title, :average_rating, :ratings_count) do
  def score
    return 0 if ratings_count < MIN_RATINGS

    # Bayesian estimates; http://stackoverflow.com/a/2134629
    (ratings_count / (ratings_count + MIN_RATINGS).to_f) * average_rating +
      (MIN_RATINGS / (ratings_count + MIN_RATINGS).to_f) * $average_rating
  end

  def <=>(book)
    if score == book.score
      return title <=> book.title
    end

    score <=> book.score
  end

  def to_s
    s = '%.2f %7d %.2f %s' % [average_rating, ratings_count, score, title]

    return s if s.length <= 80

    s[0...80-3].chomp('.') + '...'
  end
end

consumer = OAuth::Consumer.new(ENV['GOODREADS_API_KEY'],
                               ENV['GOODREADS_API_SECRET'],
                               site: 'http://www.goodreads.com')

access_token = OAuth::AccessToken.new(consumer, ENV['OAUTH_ACCESS_TOKEN'],
                                      ENV['OAUTH_ACCESS_SECRET'])

page = 1

books = []

loop do
  query = {
    v:        2,
    id:       ENV['GOODREADS_USER_ID'],
    shelf:    'to-read',
    page:     page,
    per_page: 200,
    key:      ENV['GOODREADS_API_KEY'],
  }.map {|k, v| CGI.escape(k.to_s) + '=' + CGI.escape(v.to_s) }.join('&')
  response = access_token.get("/review/list.xml?#{query}")

  reviews = Nokogiri.XML(response.body).at('reviews')

  books.concat(
    reviews.css('review').map do |book|
      Book.new(
        book.at('title').text,
        book.at('average_rating').text.to_f,
        book.at('ratings_count').text.to_i,
      )
    end
  )

  break if books.size == reviews['total'].to_i

  page += 1
end

$average_rating = books.map(&:average_rating).reduce(:+) / books.size.to_f

puts books.sort
