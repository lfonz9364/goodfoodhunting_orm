require "pry"
require "sinatra"
# require "sinatra/reloader"
require "pg"
require_relative "database_config"
require_relative "models/dish"
require_relative "models/dish_type"
require_relative "models/user"
require_relative "models/comment"

enable :sessions

helpers do

  def current_user
    User.find_by(id: session[:user_id])
  end

  def logged_in? #should return booelans
    !!current_user
  end

end

after do
  ActiveRecord::Base.connection.close
end

get '/' do
  @dishes = Dish.all
  erb :index
end

get '/dishes' do

end

get '/dishes/new' do
  @dish_types = DishType.all
  erb :new
end

post '/dishes' do
  new_dish = Dish.new
  new_dish.name = params[:name]
  new_dish.image_url = params[:image_url]
  new_dish.dish_type_id = params[:dish_type]
  new_dish.save
  redirect '/'
end

#localhost:4567/dishes/8 or drop table dishes; --> put in bottom to avoid breaking others
get '/dishes/:id' do
  @dish = Dish.find(params[:id])
  @comments = @dish.comments
  @dish_type = @dish.dish_type
  erb :show
end

delete '/dishes/:id/delete' do
  dish = Dish.find(params[:id])
  dish.delete #or .destroy
  redirect '/'
end

get '/dishes/:id/edit' do
  redirect '/session/new' unless logged_in?
  @dish = Dish.find(params[:id])
  # @dish = run_sql("SELECT * FROM dishes WHERE id = #{params[:id]}")[0]
  erb :edit
end

put '/dishes/:id' do
  redirect '/session/new' unless logged_in?

  dish = Dish.find(params[:id])
  dish.name = params[:new_name]
  dish.image_url = params[:new_image_url]
  dish.save
redirect '/'
end

get '/dish_types' do
  @dish_types = DishType.all
  erb :type
end

get '/dish_types/new' do
  #get new dishes form
  erb :new_type
end

post '/dish_types' do
  new_type = DishType.new
  new_type.name = params[:name]
  new_type.save
  redirect '/dish_types'
end

#localhost:4567/dishes?id=7 --> put in bottom to avoid breaking others
get '/dish_types/:id' do
  @dish_type = DishType.find(params[:id])
  @dishes = @dish_type.dishes
  erb :show_type
end

delete '/dish_types/:id/delete' do
  dish_type = DishType.find(params[:id])
  dish_type.delete #or .destroy
  # sql = "DELETE FROM dishes WHERE id = #{ params[:id] };"
  # run_sql(sql)
  redirect '/dish_types'
end

get '/dish_types/:id/edit' do
  @dish_type = DishType.find(params[:id])
  # @dish = run_sql("SELECT * FROM dishes WHERE id = #{params[:id]}")[0]
  erb :edit_type
end

put '/dish_types/:id' do
  dish_type = DishType.find(params[:id])
  dish_type.name = params[:new_name]
  dish_type.save
  redirect '/dish_types'
end

get '/session/new' do
  erb :login
end

post '/session' do
  user = User.find_by(email: params[:email])
  if user && user.authenticate(params[:password])
    session[:user_id] = user.id
    redirect '/'
  else
    erb :login
  end
end

delete '/session' do
  session[:user_id] = nil
  redirect '/session/new'
end

post '/comments' do
  comment = Comment.new
  comment.body = params[:body]
  comment.dish_id = params[:dish_id]
  if comment.save
    redirect "/dishes/#{comment.dish_id}"
  else
    erb :show
  end
end
