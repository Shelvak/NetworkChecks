require 'rake'
require 'bundler/setup'

require 'byebug'
require 'yaml'
require 'mtik'
require 'amazing_print'
require 'active_support/all'

require './lib/network_checks'


task default: [:run]

task :run do
  ap NetworkChecks.list_wifi_clients
end
