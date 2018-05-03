require 'colorize'

# These tasks are for local development and have no tests
namespace :watch do
  desc 'run watchdoge service on all endpoints'
  task 'all': :environment do
    Rake::Task['refill_database'].invoke
    puts "URLs: #{Rails.application.config_for(:secrets)['apie_base_uri_new']} & #{Rails.application.config_for(:secrets)['apie_base_uri_old']}"
    Endpoint.all.each do |endpoint|
      # TODO: REMOVE THIS !!!
      next if endpoint.uname == 'sirene_1_homepage'
      endpoint.http_response
      print_console_infos endpoint
    end
  end

  desc 'run a specific endpoint by uname'
  task 'one': :environment do
    ARGV.each { |a| task a.to_sym do; end } # it removes exit exception

    endpoint = Endpoint.find_by(uname: ARGV[1])
    endpoint.http_response
    print_console_infos endpoint
  end

  def print_console_infos(endpoint)
    url = ENV['DEBUG'] ? "(url: #{endpoint.uri})" : ''
    puts "#{endpoint.uname.blue} is #{status(endpoint)} #{url}" if %w[development sandbox staging production].include? Rails.env
  end

  def status(endpoint)
    case endpoint.http_response.code.to_i
    when 200
      'UP'.green
    when 206
      'INCOMPLETE'.yellow
    else
      'DOWN'.red
    end
  end
end
