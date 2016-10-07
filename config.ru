require 'rubygems'
require 'bundler'
Bundler.require

require './app'
$stdout.sync = true

run Sinatra::Application