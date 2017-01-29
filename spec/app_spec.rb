require File.expand_path '../spec_helper.rb', __FILE__

describe 'app' do

	before(:all) do 
  	@user = User.new 
  	@user.login = 'Saha'
  	@user.age = '29'
  	@user.description = 'test'
  	@user.save
  end 

	it "user create" do
		post "/users", { 
      :login => "#{@user.login}",
      :age => "#{@user.age}",
      :description => "#{@user.description}"
    }

  	expect(User.all).to_not be_empty
  	follow_redirect!
  	expect(last_request.path).to eq('/')
	end

	it "post create" do
		post "/posts", {
			:title => "test",
			:text => "test",
			:id => "#{@user.id}"
		}

	end

	it "get /" do
		get "/"
		users = User.all
		expect(users).to be_a(ActiveRecord::Relation)
		expect(last_response.body).to include('All Users')
		expect(last_request.url).to eq('http://example.org/')
		expect(last_request.path).to eq('/')
	end

	it "get /users/:id" do
		#get "/users/:id"
		#expect(users).to be_a(ActiveRecord::Relation)
		#expect(:get => "/").to respond_to("index")
		#expect(:get => "/users/id").to respond_to("user")
	end	

end