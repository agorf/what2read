require 'sinatra'
require 'what2read/book'

module What2Read
  class Server < Sinatra::Base
    ORDER_BY_COLS = %w{title authors isbn pages score rating ratings}.freeze

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

      erb :index
    end

    helpers do
      def column_order_class(name)
        @order if @order_by == name.downcase
      end

      def column_url(name)
        name.downcase!
        '?order_by=%{order_by}&amp;order=%{order}' % {
          order_by: name,
          order: @order_by == name && @order == 'asc' ? 'desc' : 'asc'
        }
      end

      def redirect_to_defaults?
        params.empty? || !ORDER_BY_COLS.include?(@order_by) ||
          !%w{asc desc}.include?(@order)
      end
    end
  end
end
