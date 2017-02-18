require 'sinatra'
require 'what2read/book'

module What2Read
  class Server < Sinatra::Base
    ORDER_BY_COLS = {
      'title'   => 'asc',
      'authors' => 'asc',
      'isbn'    => 'asc',
      'pages'   => 'desc',
      'score'   => 'desc',
      'rating'  => 'desc',
      'ratings' => 'desc',
    }.freeze

    SECONDARY_ORDER_BY = {
      'score'   => 'ratings',
      'ratings' => 'score',
      'rating'  => 'ratings',
    }

    set :root, File.expand_path('../..', File.dirname(__FILE__))

    get '/' do
      @order_by = params['order_by']
      @order = params['order']

      if redirect_to_defaults?
        return redirect '?order_by=score&order=desc'
      end

      @books = Book

      if @order_by == 'authors'
        @books = @books.
          association_join(:authors).
          group(:book_id).
          select_all(:books).
          select_more { group_concat(`authors.name`).as(:authors) }
      end

      @books = @books.order(Sequel.public_send(@order, @order_by.to_sym))

      if secondary_order_by = SECONDARY_ORDER_BY[@order_by]
        @books = @books.order_append(
          Sequel.public_send(
            ORDER_BY_COLS.fetch(secondary_order_by),
            secondary_order_by.to_sym
          )
        )
      end

      erb :index
    end

    helpers do
      def column_order(name)
        name.downcase!

        if @order_by == name
          { 'asc' => 'desc', 'desc' => 'asc' }[@order] # invert
        else
          ORDER_BY_COLS.fetch(name) # default
        end
      end

      def column_order_class(name)
        @order if @order_by == name.downcase
      end

      def column_url(name)
        name.downcase!
        "?order_by=#{name}&amp;order=#{column_order(name)}"
      end

      def redirect_to_defaults?
        params.empty? || !ORDER_BY_COLS.has_key?(@order_by) ||
          !%w{asc desc}.include?(@order)
      end
    end
  end
end
