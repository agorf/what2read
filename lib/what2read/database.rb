require 'sequel'

module What2Read
  class Database
    def self.connection
      @connection ||= Sequel.connect(adapter: 'sqlite', database: 'books.db')
    end

    def self.create_schema
      create_authors
      create_books
      create_authors_books
    end

    def self.create_authors
      connection.create_table?(:authors) do
        primary_key :id

        String :name, null: false
        String :link, null: false
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

    def self.truncate_tables!
      # authors_books is first to satisfy foreign_key constraints
      [:authors_books, :authors, :books].each do |table|
        connection[table].truncate
      end
    end

    Sequel::Model.db = connection
    create_schema
  end
end
