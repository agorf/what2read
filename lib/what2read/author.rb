require 'sequel'
require 'what2read/database'

module What2Read
  class Author < Sequel::Model
    one_to_many :books
  end
end
