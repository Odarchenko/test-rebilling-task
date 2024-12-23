# frozen_string_literal: true

require 'sidekiq'
require 'sidekiq-scheduler'
require './jobs/rebill_job'
require './jobs/rebill_processor_job'

Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://localhost:6379/0' }

  config.on(:startup) do
    Sidekiq.schedule = YAML.load_file('config/schedule.yml') if File.exist?('config/schedule.yml')
    Sidekiq::Scheduler.reload_schedule!
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://localhost:6379/0' }
end
