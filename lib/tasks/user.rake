# frozen_string_literal: true

namespace :user do
  desc 'Create a user account from EMAIL and PASSWORD'
  task create: :environment do
    user = User.new(email: ENV['EMAIL'], password: ENV['PASSWORD'], password_confirmation: ENV['PASSWORD'])
    if user.save
      puts 'Created'.bold.green + %( user with email "#{user.email}").green
    else
      puts 'Failed'.bold.red + ' to create user:'.red
      user.errors.full_messages.each do |err|
        puts "* #{err}".red
      end
      exit 1
    end
  end
end
