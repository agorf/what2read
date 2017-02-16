require 'sinatra'
require 'what2read/book'

module What2Read
  class Server < Sinatra::Base
    set :root, File.expand_path('../..', File.dirname(__FILE__))

    get '/' do
      @books = Book.reverse(:score)
      erb :index
    end
  end
end
