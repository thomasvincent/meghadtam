require 'addressable/uri'
require 'celluloid'
require 'celluloid/io'
require 'faraday'
require 'forwardable'
require 'hashie'
require 'json'
require 'pathname'
require 'semverse'
require 'httpclient'
require 'meghadtam/httpclient_ext'

JSON.create_id = nil

module Ridley
  CDH_VERSION = '11.4.0'.freeze

  class << self
    extend Forwardable

    def_delegator "Meghadtam::Logging", :logger
    alias_method :log, :logger

    def_delegator "Meghadtam::Logging", :logger=
    def_delegator "Meghadtam::Logging", :set_logger

    # @return [Meghadtam::Client]
    def new(*args)
      Client.new(*args)
    end

    # Create a new Cloudera REST connection from a config
    #
    # @param [#to_s] filepath
    #   the path to the Cloudera Config
    #
    # @param [hash] options
    #   list of options to pass to the Cloudera connection (@see {meghadtam::Client#new})
    #
    # @return [meghadtam::Client]
    def from_chef_config(filepath = nil, options = {})
      config = Ridley::Chef::Config.new(filepath).to_hash

      config[:validator_client] = config.delete(:validation_client_name)
      config[:validator_path]   = config.delete(:validation_key)
      config[:client_name]      = config.delete(:node_name)
      config[:server_url]       = config.delete(:chef_server_url)
      if config[:ssl_verify_mode] == :verify_none
        config[:ssl] = {verify: false}
      end

      Client.new(config.merge(options))
    end

    def open(*args, &block)
      Client.open(*args, &block)
    end

    # @return [Pathname]
    def root
      @root ||= Pathname.new(File.expand_path('../', File.dirname(__FILE__)))
    end
  end

  require_relative 'meghadtam/mixin'
  require_relative 'meghadtam/logging'
  require_relative 'meghadtam/logger'
  require_relative 'meghadtam/cdh_object'
  require_relative 'meghadtam/cdh_objects'
  require_relative 'meghadtam/client'
  require_relative 'meghadtam/connection'
  require_relative 'meghadtam/cdh'
  require_relative 'meghadtam/middleware'
  require_relative 'meghadtam/resource'
  require_relative 'meghadtam/resources'
  require_relative 'meghadtam/sandbox_uploader'
  require_relative 'meghadtam/version'
  require_relative 'meghadtam/errors'
end

Celluloid.logger = Meghadtam.logger
