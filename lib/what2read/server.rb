require 'sinatra'
require 'uri'
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
      'pages'   => 'score',
      'score'   => 'ratings',
      'rating'  => 'ratings',
      'ratings' => 'score',
    }

    set :root, File.expand_path('../..', File.dirname(__FILE__))

    get '/' do
      @order_by = params['order_by']
      @order = params['order']

      if redirect_to_defaults?
        return redirect '?order_by=score&order=desc'
      end

      @books = Book.eager_graph(:authors, :shelves)

      unless params['shelf'].to_s.empty?
        @shelf = params['shelf']
        @books = @books.where(shelves__name: @shelf)
      end

      if @order_by == 'authors'
        order_msg = @order == 'asc' ? :order : :reverse
        @books = @books.
          group(:authors_books__book_id).
          public_send(order_msg) { group_concat(:authors__name) }
      else
        @books = @books.order(Sequel.public_send(@order, @order_by.to_sym))
      end

      if secondary_order_by = SECONDARY_ORDER_BY[@order_by]
        @books = @books.order_append(
          Sequel.public_send(
            ORDER_BY_COLS.fetch(secondary_order_by),
            secondary_order_by.to_sym
          )
        )
      end

      @books = @books.all

      erb :index
    end

    helpers do
      def column_order(name)
        if @order_by == name
          { 'asc' => 'desc', 'desc' => 'asc' }[@order] # invert
        else
          ORDER_BY_COLS.fetch(name) # default
        end
      end

      def column_order_class(name)
        @order if @order_by == name.downcase
      end

      def params_to_query(options)
        URI.encode_www_form(params.merge(options))
      end

      def redirect_to_defaults?
        !ORDER_BY_COLS.has_key?(@order_by) || !%w{asc desc}.include?(@order)
      end
    end
  end
end
