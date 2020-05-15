require 'sinatra'
require 'dm-core'
require 'dm-migrations'

#
DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/users.db")

#create a model for user account
class Account
  include DataMapper::Resource
  property :id, Serial
  property :username, Text, :required => true
  property :password, Text, :required => true
  property :firstName, Text, :required => true
  property :lastName, Text
  property :totWin, Integer, :required => true
  property :totLoss, Integer, :required => true
  property :totProfit, Integer, :required => true
  
end

# Perform basic sanity checks and initialize all relationships
DataMapper.finalize

DataMapper.auto_upgrade!
#DataMapper.auto_migrate!

