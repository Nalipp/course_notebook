require 'pry'

require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

configure do
  enable :sessions
  set :session_secret, 'secret'
end

def data_path
  File.expand_path("../data", __FILE__)
end

def load_file_content(path)
  content = File.read(path)
  if File.extname(path) == ".txt"
    content
  else
    session[:message] = "Please use the .txt file format"
    redirect "/"
  end
end

def validate_filename(filename)
  if filename.length > 1000
    session[:message] = "filename too long"
    redirect '/'
  elsif filename.length < 2
    session[:message] = "filename too short"
    redirect '/'
  elsif params[:filename][-4..-1] != ".txt"
    params[:filename] + ".txt"
  end
end

def validate_content(content)
  if content.length > 1000000
    session[:message] = "content too long"
    redirect '/new'
  end
end

get '/' do
  pattern = File.join(data_path, "*")

  @files = Dir.glob(pattern).map do |path|
    File.basename(path)
  end
  erb :index
end

get '/courses/:filename' do
  file_path = File.join(data_path, params[:filename])
  if File.file?(file_path)
    @content = load_file_content(file_path)
  else
    session[:message] = "#{params[:filename]} does not exist."
    redirect "/"
  end
  erb :content
end

get '/new' do
  erb :new
end

post '/create' do
  filename = validate_filename(params[:filename])
  content = validate_content(params[:content])

  file_path = File.join(data_path, filename)

  File.write(file_path, params[:content])

  session[:message] = "#{params[:filename]} has been created."
  redirect "/"
end

get '/:filename/edit' do
  @filename = params[:filename]
  content_path = File.join(data_path, @filename)
  @contents = File.read(content_path)

  erb :edit
end

post '/:filename' do
  file_path = File.join(data_path, params[:filename])
  File.write(file_path, params[:content])

  redirect "/"
end

post '/:filename/delete' do
  file_path = File.join(data_path, params[:filename])

  File.delete(file_path)

  session[:message] = "#{params[:filename]} has been deleted."
  redirect "/"
end
