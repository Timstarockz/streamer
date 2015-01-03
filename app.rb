# 
# status streamer
# app.rb
# by Tim :D
# 

require 'sinatra'
require 'sinatra/reloader'

require 'json'
require 'csv'


require 'pry'


def getArticles
  $articles = []
  rows = []
  if File.exist?("data.csv")
    CSV.foreach("data.csv") do |row|
      rows.insert(-1, row)
    end
  end
  
  rows.each do |t|
    string = t.first.gsub(/:([a-zA-z]+)/,'"\\1"').gsub('=>', ': ')
    hash = JSON.parse(string, :quirks_mode => true)
    $articles.push(hash)
  end
  
  $articles.reverse!
end

get '/' do
  getArticles
  
  '<p>&nbsp;</p>
  <a href="/stream">Go to Stream</a>
  <p>&nbsp;</p>
   <a href="/static">Go to static stream</a>
   <p>&nbsp;</p>
   <a href="/post">post to stream</a>'
end

# before do
#   content_type :txt
# end

def getLatestArticles
  $new_data = []
  rows = []
  if File.exist?("data.csv")
    CSV.foreach("data.csv") do |row|
      rows.insert(-1, row)
    end
  end

  rows.each do |t|
    string = t.first.gsub(/:([a-zA-z]+)/,'"\\1"').gsub('=>', ': ')
    hash = JSON.parse(string, :quirks_mode => true)
    $new_data.push(hash)
  end

  $new_data = $new_data - $articles
  
  $new_data
end

def clearNew
  puts
  puts "fio"
  $new_data = []
  $new_data
end


get '/stream' do
  stream(:keep_open) do |out|
    # out << "starting stream..."
    out << "<p>&nbsp;</p>"
    out << '<img src="/imgs/spinny.gif">'
    out << "<p>&nbsp;</p>"
    
    getArticles
    if $articles.length > 0
      $articles.each do |sym|
        out << "#{sym["text"]} <br> #{sym["date"]} <p>&nbsp;</p>"
      end
    end
    
    while true
      sleep 0.1
      # out << "restart loop"

      if $flag == true
        out << "#{$hash["text"]} <br> #{$hash["date"]} <p>&nbsp;</p>"
        out << "<script> window.scrollTo(0,document.body.scrollHeight); </script>"
      else
        # out << "..."
      end
      
    end # while
    
  end # stream
  
end # get

get '/static' do
  getArticles
  
  $articles.to_a
  
  out = 
  "Static Stream
  <p>&nbsp;</p>"
  
  $articles.each do |sym|
    out = out + "#{sym["text"]} <br> #{sym["date"]} <p>&nbsp;</p>"
  end
  
  out
end

get '/post' do
  if params[:message]
    "<p>&nbsp;</p>
    Message Posted!
    <p>&nbsp;</p>" + 
    '
    <form method="post" action="/post">
          <input type="text" name="text" required autofocus>
					<button id="search-button" type="submit" class="button postfix">Post to stream</button>
		</form>
    '
  else
    '
    <form method="post" action="/post">
          <input type="text" name="text" required autofocus>
					<button id="search-button" type="submit" class="button postfix">Post to stream</button>
		</form>
    '
  end
end

post '/post' do
  text = params[:text]
  
  $hash = {
    "text" => text,
    "date" => Time.now
  }
  
  $flag = true
  
  sleep 0.1
  article = [$hash.to_json]
  $hash = {}
  
  $flag = false
  
  CSV.open("data.csv", "a") do |csv|
    csv << article
  end
  
  redirect '/post?message=didpost'
end