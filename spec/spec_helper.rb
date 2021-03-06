require 'rubygems'
require 'bundler'
require 'buff/ruby_engine'

def setup_rspec
  require 'rspec'
  require 'json_spec'
  require 'webmock/rspec'

  Dir[File.join(File.expand_path("../../spec/support/**/*.rb", __FILE__))].each { |f| require f }

  RSpec.configure do |config|
    config.include Meghadtam::SpecHelpers
    config.include Meghadtam::RSpec::ChefServer
    config.include JsonSpec::Helpers

    config.mock_with :rspec
    config.treat_symbols_as_metadata_keys_with_true_values = true
    config.filter_run focus: true
    config.run_all_when_everything_filtered = true

    config.before(:suite) do
      WebMock.disable_net_connect!(allow_localhost: true, net_http_connect_on_start: true)
      Meghadtam::RSpec::Cloudera.start
    end

    config.before(:all) { Ridley.logger = Celluloid.logger = nil }

    config.before(:each) do
      Celluloid.shutdown
      Celluloid.boot
      clean_tmp_path
      Meghadtam::RSpec::Cloudera.start.clear_data
    end
  end
end

if Buff::RubyEngine.mri? && ENV['CI'] != 'true'
  require 'spork'

  Spork.prefork do
    setup_rspec
  end

  Spork.each_run do
    require 'meghadtam'
  end
else
  require 'meghadtam'
  setup_rspec
end
