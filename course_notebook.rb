require 'pry'

require "sinatra"
require "sinatra/reloader"
require "sinatra/content_for"
require "tilt/erubis"
require "redcarpet"

configure do
  enable :sessions
  set :session_secret, 'secret'
end

def data_path
  File.expand_path("../data", __FILE__)
end

def render_markdown(text)
  markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
  markdown.render(text)
end

def load_file_content(path)
  content = File.read(path)
  if File.extname(path) == ".md"
    render_markdown(content)
  else
    session[:message] = "Please use the .md file format"
    redirect "/"
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

def validate_filename(filename)
  if filename.length > 1000
    session[:message] = "filename too long"
    redirect '/'
  elsif filename.length < 2
    session[:message] = "filename too short"
    redirect '/'
  elsif params[:filename][-3..-1] != ".md"
    params[:filename] + ".md"
  end
end

post '/create' do
  filename = validate_filename(params[:filename])
  file_path = File.join(data_path, filename)

  File.write(file_path, params[:content])

  session[:message] = "#{params[:filename]} has been created."
  redirect "/"
end
