require "rubygems"
require "sinatra"
require "sinatra/activerecord"
require "json"
require "./models/user"
require "./models/post"

get "/" do
	@users = User.all
	erb :"index"
end

get "/posts/:id" do
	@user = User.find(params[:id])
	@posts = @user.posts
	erb :"posts"
end

delete "/delete_post" do
	post = Post.find(params[:id])
	post.destroy
	redirect "/posts/#{params[:user_id]}"
end

delete "/delete" do
	user = User.find(params[:id])
	user.destroy
	redirect "/"
end

post "/add_post" do
	user = User.find(params[:id])

	post = Post.new
	post.title = params[:title]
	post.text = params[:text]
	post.user = user

	if post.save
		redirect "posts/#{params[:id]}"
	else

	end
end

post "/add_user" do
	user = User.new
	user.login = params[:login]
	user.age = params[:age]
	user.description = params[:description]

	if user.save
		redirect "/"
	else

	end
end

get '/users.json' do
  @users = User.all
  content_type :json
  @users.to_json
end

get '/posts.json' do
  @posts = Post.all
  content_type :json
  @posts.to_json
end

get '/users.html' do
	result = '<ul>'
  all = User.all
  all.each do |user|
  	result = result + "<li>#{user.login}</li>"
  	result = result + "<li>#{user.age}</li>"
  	result = result + "<li>#{user.description}</li><br><br>"
  end
  result = result + '</ul>'
  content_type 'text/html,  :charset => utf-8'
  "#{result}"
end

ActiveRecord::Base.configurations = YAML::load(IO.read('config/database.yml'))
ActiveRecord::Base.establish_connection(:development)