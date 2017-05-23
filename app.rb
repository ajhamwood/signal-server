require 'sinatra/base'

module SignalServer
  class App < Sinatra::Base
    get '/' do
      p [:ping]
      status 200
      body ''
    end
  end
end
