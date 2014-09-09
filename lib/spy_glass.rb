require 'active_support/cache'
require 'active_support/inflector/inflections'
require 'faraday'
require 'faraday_middleware'
require 'json'

require 'spy_glass/version'

module SpyGlass
  IDENTITY = ->(v){v}

  def self.build(identifier = :base, &block)
    raise ArgumentError, 'must pass a block' unless block_given?

    # retrieve the proxy class
    klass = SpyGlass::Proxy.const_get(identifier.to_s.classify)

    # build and configure proxy instance
    proxy = klass.new
    proxy.configure(&block)
    proxy
  end

  module Proxy
    class Base
      extend Forwardable
      def_delegators :@configuration,
        :source_uri, :content_type,
        :parser, :generator, :transformation,
        :cache

      def initialize(configuration = SpyGlass::Configuration.new, &block)
        @configuration = configuration
      end

      def configure
        yield @configuration if block_given?
      end

      def call
        cache.fetch(source_uri.call) do
          generator.(transformation.(parser.(connection.get.body)))
        end
      end

      def connection
        Faraday.new(url: source_uri.call) do |conn|
          conn.headers['Content-Type'] = content_type
          conn.response :caching, cache
          conn.adapter Faraday.default_adapter
        end
      end

      def to_proc
        _proxy = self

        # sinatra adapter
        lambda do
          content_type _proxy.content_type
          _proxy.call
        end
      end
    end # class Base

    class Json < Base
      def initialize(*)
        super

        configure do |config|
          config.content_type = 'application/json'
          config.define_parser { |body| JSON.parse(body) }
          config.define_generator { |body| JSON.pretty_generate(body) }
        end
      end
    end # class Json
  end # module Proxy

  class Configuration
    attr_accessor :cache, :content_type, :generator,
                  :parser, :source_uri, :transformation

    def initialize
      @content_type   = 'text/html'
      @cache          = ActiveSupport::Cache::NullStore.new
      @parser         = SpyGlass::IDENTITY
      @generator      = SpyGlass::IDENTITY
      @transformation = SpyGlass::IDENTITY
    end

    def define_source_uri(callable = Proc.new)
      @source_uri = callable
    end

    def define_parser(callable = Proc.new)
      @parser = callable
    end

    def define_generator(callable = Proc.new)
      @generator = callable
    end

    def define_transformation(callable = Proc.new)
      @transformation = callable
    end
  end # class Configuration
end # module SpyGlass
