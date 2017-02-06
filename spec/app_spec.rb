require File.expand_path "../spec_helper.rb", __FILE__

describe "app" do

  before(:all) do
    @user = User.new
    @user.login = "Saha"
    @user.age = "29"
    @user.description = "test"
    @user.save

    @post = Post.new
    @post.title = "test"
    @post.text = "test"
    @post.user_id = @user.id
    @post.save
  end

  it "user create" do
    post "/users", {
    :login => "#{@user.login}",
    :age => "#{@user.age}",
    :description => "#{@user.description}"
    }

    expect(User.all).to_not be_empty
    follow_redirect!
    expect(last_request.path).to eq("/")
  end

  it "post create" do
    post "/posts", {
    :title => "#{@post.title}",
    :text => "#{@post.text}",
    :id => "#{@user.id}"
    }

    follow_redirect!
    expect(last_request.path).to eq("/users/#{@user.id}")
  end

  it "get /" do
    get "/"

    users = User.all
    expect(users).to be_a(ActiveRecord::Relation)
    expect(last_response.body).to include("All Users")
    expect(last_request.url).to eq("http://example.org/")
    expect(last_request.path).to eq("/")
  end

  it "get /users/:id" do
    get "/users/#{@user.id}"
    expect(last_response.body).to include("Posts of")
    expect(last_response.status).to eq 200
  end

  it "delete post" do
    delete "/posts/#{@post.id}/users/#{@user.id}"

    expect(Post.all).to_not include(@post)

    follow_redirect!
    expect(last_request.path).to eq("/users/#{@user.id}")
  end

  it "delete user" do
    delete "/users/#{@user.id}"

    expect(User.all).to_not include(@user)

    follow_redirect!
    expect(last_request.path).to eq("/")
  end

  it "users json" do
    get "/users_json"

    users = User.all
    expect(last_response.body).to eq users.to_json
  end

  it "posts json" do
    get "/posts_json"

    posts = Post.all
    expect(last_response.body).to eq posts.to_json
  end

  it "users all" do
    get "/users"

    users = User.all
    expect(users).to be_a(ActiveRecord::Relation)
    expect(last_response.body).to include("Users html")
  end

end