require "rubygems"
require "sinatra"
require "sinatra/activerecord"
require "json"
require "./models/user"
require "./models/post"

get "/" do
	@users = User.all
	haml :"index"
end

get "/users/:id" do
	@user = User.find params[:id]
	@posts = @user.posts
	erb :"user"
end

delete "/posts/:id/users/:user_id" do
	post = Post.find params[:id]
	post.destroy
	redirect "/users/#{params[:user_id]}"
end

delete "/users/:id" do
	user = User.find params[:id]
	user.destroy
	redirect "/"
end

post "/posts" do
	user = User.find params[:id]

	post = Post.new
	post.title = params[:title]
	post.text = params[:text]
	post.user = user

	if post.save
		redirect "/users/#{params[:id]}"
	else
		redirect "/"
	end
end

post "/users" do
	user = User.new
	user.login = params[:login]
	user.age = params[:age]
	user.description = params[:description]

	user.save
	redirect "/"
end

get '/users_json' do
	@users = User.all
	content_type :json
	@users.to_json
end

get '/posts_json' do
	@posts = Post.all
	content_type :json
	@posts.to_json
end

get '/users' do
	@users = User.all
	
	erb :"users"
end

ActiveRecord::Base.configurations = YAML::load(IO.read('config/database.yml'))
ActiveRecord::Base.establish_connection(:development)