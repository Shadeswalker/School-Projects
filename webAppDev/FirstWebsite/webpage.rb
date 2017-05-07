require 'sinatra'
require 'data_mapper'

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/webpage.db")   

#creation of the database
class User
	include DataMapper::Resource
	property :id, Serial
	property :username, Text, :required => true
	property :password, Text, :required => true
	property :creation_date, DateTime
	property :edit, Boolean, :required => true, :default => false
end

class Post
	include DataMapper::Resource
	property :id, Serial
	property :content, Text, :required => true
	property :posted_by, Text, :required => true
	property :created_at, DateTime
	property :updated_at, DateTime
end

DataMapper.finalize.auto_upgrade!  

get '/' do
	@title = "Home"
	erb :home
end

get '/about' do
	@title = "About"
	erb :about
end

get '/notfound' do
	@title = "Error 404"
	erb :notfound
end

get '/login' do
	@title = "Login"
	erb :login
end

post '/login' do
	$credentials = [params[:username],params[:password]]
	@Users = User.first(:username => $credentials[0])
	$can_edit = @Users.edit  #useful for /layout (line  21), and other verifications for admin privileges
	if @Users
		if @Users.password == $credentials[1]
			redirect '/'
		else
			$credentials = ['','']
			redirect '/loginfailed'
		end
	else
		$credentials = ['','']
		redirect '/loginfailed'
	end
end

get '/logout' do
	$credentials = ['','']
	$can_edit = false
	redirect '/'
end

get '/loginfailed' do
	@title = "Login Failed"
	erb :loginfailed
end

get '/createaccount' do
	@title = "Create Account"
	erb :createaccount
end


post '/createaccount' do
	if params[:password] != params[:password2] #verifying if both passwords match
		redirect '/createaccount2'
	else
		u = User.new
		u.username = params[:username]
		u.password = params[:password]
		u.creation_date = Time.now
		if u.username == "arjun" and u.password == "gupta"
			u.edit = true
		end
		u.save
		redirect "/login"
	end
end

get '/createaccount2' do
	@title = "Create Account"
	erb :createaccount2
end

post '/createaccount2' do
	if :password != :password2
		redirect '/createaccount2'
	else
		u = User.new
		u.username = params[:username]
		u.password = params[:password]
		u.creation_date = Time.now
		if u.username == "arjun" and u.password == "gupta"
			u.edit = true
		end
		u.save
		redirect "/login"
	end
end

get '/edit' do
	if $credentials and $credentials[0] != ''
		if $can_edit
			@title = "Edit"
			@comments = File.open("views/home.erb", "r")
			@content = @comments.read
			@comments.close
			erb :edit
		else
			redirect '/denied'
		end
	else
		redirect '/login'
	end
end

post '/edit' do
	if $can_edit
		@comments = File.open("views/home.erb" , "w")
		@comments.write(params[:comments])
		@comments.close
		#appending logfile :
		@log = File.open("logfile.txt", "a")
		@log.write("Edited by : [")
		@log.write($credentials[0])
		@log.write("] the : [")
		@log.write(Time.now)
		@log.write("]   ------   ")
		@log.close
	else
		redirect '/denied'
	end
	redirect '/'
end

get '/resethome' do
	@origintext = File.open("views/resethome.erb", "r")
	@originaltext = @origintext.read
	@origintext.close
	@comments = File.open("views/home.erb" , "w")
	@comments.write(@originaltext) #replacing the modified text by the original text contained in resethome.erb
	@comments.close
	#appending logfile :
	@log = File.open("logfile.txt", "a")
	@log.write("Reseted by : [")
	@log.write($credentials[0])
	@log.write("] the : [")
	@log.write(Time.now)
	@log.write("]   ------   ")
	@log.close
	redirect '/'
end

get '/admincontrols' do
	if $can_edit
		@title = "Admin Controls"
		@allusers = User.all
		erb :admincontrols
	else
		redirect '/denied'
	end
end

put '/user/:someone' do
	u = User.first(:username => params[:someone])
	u.edit = params[:edit] ? 1 : 0
	u.save
	redirect '/admincontrols'
end

delete '/user/delete/:someone' do
	u = User.first(:username => params[:someone])
	u.destroy
	redirect '/admincontrols'
end

get '/forum' do
	if $credentials and $credentials[0] != ''
		@posts = Post.all :order => :id.desc
		@title = 'Forum'
		erb :forum
	else
		redirect '/login'
	end
end

post '/forum' do
	p = Post.new
	p.content = params[:content]
	p.posted_by = $credentials[0]
	p.created_at = Time.now
	p.updated_at = Time.now
	p.save
	#appending logfile :
		@log = File.open("logfile.txt", "a")
		@log.write("Post added by : [")
		@log.write($credentials[0])
		@log.write("] the : [")
		@log.write(Time.now)
		@log.write("]   ------   ")
		@log.close
	redirect '/forum'
end

get '/forum/:id' do
	@post = Post.get params[:id]
	if @post.posted_by == $credentials[0] or $can_edit
		@title = "Edit post ##{params[:id]}"
		erb :postedit
	else
		redirect '/denied2'
	end
end

put '/forum/:id' do
	p = Post.get params[:id]
	p.content = params[:content]
	p.updated_at = Time.now
	p.save
	#appending logfile :
		@log = File.open("logfile.txt", "a")
		@log.write("Post ##{params[:id]} edited by: [")
		@log.write($credentials[0])
		@log.write("] the : [")
		@log.write(Time.now)
		@log.write("]   ------   ")
		@log.close
	redirect '/forum'
end

get '/forum/:id/delete' do
	@post = Post.get params[:id]
	if @post.posted_by == $credentials[0] or $can_edit
		@title = "Confirm deleting post ##{params[:id]}"
		erb :postdelete
	else
		redirect '/denied2'
	end
end

delete '/forum/:id' do
	p = Post.get params[:id]
	p.destroy
	#appending logfile :
		@log = File.open("logfile.txt", "a")
		@log.write("Post ##{params[:id]} deleted by: [")
		@log.write($credentials[0])
		@log.write("] the : [")
		@log.write(Time.now)
		@log.write("]   ------   ")
		@log.close
	redirect '/forum'
end

get '/denied' do
	@title = "Access Denied"
	erb :denied
end

not_found do  
	status 404  
	redirect '/notfound'  
end  

