# frozen_string_literal: true

require 'shoulda/matchers'
require 'active_record'
require 'database_cleaner/active_record'
require 'rspec-sidekiq'

RSpec.configure do |config|
  ActiveRecord::Base.establish_connection(
    adapter: 'sqlite3',
    database: 'db/test.sqlite3'
  )

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.include Shoulda::Matchers::ActiveModel, type: :model
  config.include Shoulda::Matchers::ActiveRecord, type: :model

  config.before(:suite) do
    DatabaseCleaner[:active_record].strategy = :transaction
    DatabaseCleaner[:active_record].clean_with(:truncation)
  end

  config.before do
    DatabaseCleaner[:active_record].start
  end

  config.after do
    DatabaseCleaner[:active_record].clean
  end

  Sidekiq::Testing.fake!
end
