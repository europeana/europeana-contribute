# frozen_string_literal: true

require 'sidekiq/api'

PID_FILE = File.join(Rails.root, 'tmp', 'pids', 'sidekiq.test.pid')
LOG_FILE = File.join(Rails.root, 'log', 'sidekiq.test.log')
STARTUP_WAIT = 40

def read_pid
  return nil unless File.exist?(PID_FILE)
  pid = File.read(PID_FILE).strip
  pid.to_i unless pid.blank?
end

def bundle_exec(cmd)
  system("RAILS_ENV=#{ENV['RAILS_ENV']} bundle exec #{cmd}")
end

def sidekiq_running?
  Sidekiq::ProcessSet.new.any? { |ps| ps['pid'] == read_pid }
end

def start_sidekiq
  FileUtils.mkdir_p(File.dirname(PID_FILE)) unless File.directory?(File.dirname(PID_FILE))
  bundle_exec("sidekiq -L #{LOG_FILE} -P #{PID_FILE} -d")
  wait_for_sidekiq(STARTUP_WAIT)
end

def wait_for_sidekiq(retries)
  while retries.nonzero?
    return if sidekiq_running?
    retries -= 1
    sleep 1
  end
  fail "Sidekiq did not start after checking #{STARTUP_WAIT} times."
end

def stop_sidekiq
  bundle_exec("sidekiqctl stop #{PID_FILE}")
end

RSpec.configure do |config|
  config.before(:each) do |example|
    if example.metadata[:sidekiq]
      start_sidekiq unless sidekiq_running?
      Sidekiq::Testing.disable!
    end
  end

  config.after(:each) do |example|
    Sidekiq::Testing.fake! if example.metadata[:sidekiq]
  end

  config.after(:suite) do
    stop_sidekiq
  end
end
