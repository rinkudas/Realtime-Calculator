require 'rubygems'
require 'sinatra'
require 'pusher'
require 'dentaku'
require 'data_mapper' # metagem, requires common plugins too.

# need install dm-sqlite-adapter
DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/calculator.db")

class Calculator
  include DataMapper::Resource
  property :id, Serial
  property :equation, String
  property :value, String
  property :created_at, DateTime
end

# Perform basic sanity checks and initialize all relationships
# Call this when you've defined all your models
DataMapper.finalize

# automatically create the Calculator table
Calculator.auto_upgrade!

pusher = Pusher::Client.new(
  app_id: '254389',
  key: 'c1b3866b4dc8a46e907c',
  secret: '9172818b3b5efa5217b8',
  cluster: 'ap1',
  encrypted: true
)

get '/' do
  # get the latest 10 calculations
  @calcs = Calculator.all(:order => [ :id.desc ], :limit => 10)
  erb :index
end

post '/notification' do
  message = params[:message]
  # calculation = eval(message)
  calculator = Dentaku::Calculator.new
  calculation = calculator.evaluate(message)
  # p message
  # p calculation
  # p "1"*100
  Calculator.create!(equation: message, value: calculation, created_at: Time.now)
  pusher.trigger('notifications', 'new_notification', {
    equation: message,
    message: calculation
  })
end

