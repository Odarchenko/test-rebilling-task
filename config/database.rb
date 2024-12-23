# frozen_string_literal: true

# config/database.rb
require 'active_record'

# Establishing connection to SQLite3 database
ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'db/development.sqlite3'
)
