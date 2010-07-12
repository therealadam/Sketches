require 'sinatra'

class Loader < Sinatra::Base
  
  get '/posts' do
    @env['posts'] = [1,2,3]
    forward
  end
  
end

class Render < Sinatra::Base
  
  get '/posts' do
    @env['posts'].map { |n| "A number: #{n}" }.join("\n")
  end
  
end

use Loader
run Render