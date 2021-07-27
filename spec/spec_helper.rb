require 'rspec'
require 'pg'
require 'album'
require 'artist'
require 'song'
require 'pry'

# Shared code for clearing tests between runs and connecting to the DB will also go here.

DB = PG.connect({:dbname => 'record_store_test', :password => 'epicodus'})

RSpec.configure do |config|
  config.after(:each) do
    DB.exec("DELETE FROM albums *;")
    DB.exec("DELETE FROM songs *;") 
    DB.exec("DELETE FROM artists *;") 
  end
end