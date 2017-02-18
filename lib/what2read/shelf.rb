require 'sequel'
require 'what2read/database'

module What2Read
  class Shelf < Sequel::Model
    many_to_many :books
  end
end
