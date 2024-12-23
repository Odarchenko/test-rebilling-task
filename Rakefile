# frozen_string_literal: true

require 'active_record'
require 'yaml'
require 'erb'
require 'rake'
require 'active_record_migrations'

# Load the database configuration from config/database.yml
db_config = YAML.load(ERB.new(File.read('config/database.yml')).result, aliases: true)

# Establish a connection to the database
ActiveRecord::Base.establish_connection(db_config['development'])

ActiveRecordMigrations.configure do |c|
  c.yaml_config = 'config/database.yml'
end
# Include the migrations tasks
ActiveRecordMigrations.load_tasks
