require 'sequel'
require 'what2read/database'

module What2Read
  class Author < Sequel::Model
    many_to_many :books
  end
end
