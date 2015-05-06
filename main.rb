require 'sinatra'
require 'sinatra/reloader'
require_relative 'db_config'
require_relative 'checkpoint_race_user'
require_relative 'race'
require_relative 'user'
require_relative 'checkpoint'
require 'pry'

enable :sessions

before do
		@user = current_user
end

after do
	ActiveRecord::Base.connection.close
end

get '/' do
  erb :index
end

get '/register' do
	erb :register
end

get '/login' do
	erb :login
end

get '/race' do
	erb :race
end

post '/race/new' do
	race = Race.create(name: "New Race", created_at: Time.now)
	checkpoints = [
		CheckpointRaceUser.create(checkpoint_id: 1, race_id: race.id),
		CheckpointRaceUser.create(checkpoint_id: 2, race_id: race.id),
		CheckpointRaceUser.create(checkpoint_id: 3, race_id: race.id),
		CheckpointRaceUser.create(checkpoint_id: 4, race_id: race.id)]
	redirect to '/race'
end

get '/status' do
	erb :status
end

get '/checkpoints' do
	@checkpoints = Checkpoint.all
	erb :checkpoints
end

get '/checkpoints/new' do
	erb :new_checkpoint
end

post '/checkpoints/new' do
	Checkpoint.create( name: params[:name], description: params[:description], latitude: params[:latitude], longitude: params[:longitude])
		redirect to '/checkpoints'
end

get '/api/checkpoints' do
	content_type :json
	checkpoints = Checkpoint.all
	checkpoints.to_json
end

# LOGIN
post '/signup' do
	@user = User.create( user_name: params[:username], email: params[:email], password: params[:password])
		session[:user_id] = @user.id
	redirect to '/'
end


# SESSION STUFF
post '/session' do
	@user = User.where(email: params[:email]).first
	if @user && @user.authenticate(params[:password])
		session[:user_id] = @user.id
		redirect to '/'
	else
		erb :login
	end
end

delete '/session' do
	session[:user_id] = nil
	redirect to '/'
end




# HELPERS

helpers do
	def logged_in?
		!!current_user
	end

	def current_user
			User.find_by(id: session[:user_id])
	end
end

