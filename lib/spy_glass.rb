require 'active_support/cache'
require 'active_support/inflector/inflections'
require 'faraday'
require 'json'
require 'logger'

require 'spy_glass/version'

module SpyGlass
  class Proxy
    IDENTITY = ->(v){v}

    attr_accessor :content_type, :cache
    attr_reader :host, :parser, :generator, :transformation

    def initialize(host)
      @host           = host
      @content_type   = nil
      @cache          = ActiveSupport::Cache::NullStore.new
      @parser         = IDENTITY
      @generator      = IDENTITY
      @transformation = IDENTITY
      yield self if block_given?
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

    def call(context)
      cache.fetch [host, context.request.params.sort] do
        connection = Faraday.new(url: host) do |conn|
          conn.params.update context.request.params
          conn.headers.update context.headers
          conn.response :raise_error
          conn.adapter Faraday.default_adapter
        end

        response = connection.get(context.request.path)

        generator.(transformation.(parser.(response.body)))
      end
    rescue Faraday::ClientError => e
      Rack::Response.new([[e.message], 500, {}]).finish
    end

    def to_proc
      _proxy = self

      # sinatra adapter
      lambda do
        content_type _proxy.content_type || request.content_type
        _proxy.call(self)
      end
    end
  end # class Proxy
end # module SpyGlass
