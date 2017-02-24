require 'logger'
require 'sequel'

module What2Read
  class Database
    def self.connection
      @connection ||= Sequel.connect(adapter: 'sqlite', database: 'books.db',
                                     loggers: [Logger.new($stdout)])
    end

    def self.create_schema
      create_authors
      create_shelves
      create_books
      create_authors_books
      create_books_shelves
    end

    def self.create_authors
      connection.create_table?(:authors) do
        primary_key :id

        String :name, null: false
        String :link, null: false
      end
    end

    def self.create_shelves
      connection.create_table?(:shelves) do
        primary_key :id

        String :name, null: false, unique: true
      end
    end

    def self.create_books
      connection.create_table?(:books) do
        primary_key :id

        String  :isbn, fixed: true, size: 13, unique: true # may be missing from Goodreads data
        String  :title, null: false
        Integer :pages # may be missing from Goodreads data
        Float   :rating, null: false
        Integer :ratings, null: false
        Float   :score, null: false, default: 0
        String  :link, null: false, unique: true
      end
    end

    def self.create_authors_books
      connection.create_join_table?(author_id: :authors, book_id: :books)
    end

    def self.create_books_shelves
      connection.create_join_table?(shelf_id: :shelves, book_id: :books)
    end

    def self.truncate_tables!
      # Join tables listed first to satisfy foreign_key constraints
      [:authors_books, :books_shelves, :authors, :books, :shelves].each do |table|
        connection[table].truncate
      end
    end

    Sequel::Model.db = connection
    create_schema
  end
end
