# SpyGlass

SpyGlass is a utility for defining [web content transformation proxies](http://www.w3.org/TR/ct-guidelines/). Be aware that the W3C guideline is not yet fully covered. For instance, `X-Device-*` headers are not yet implemented. The API of this library is likely to change quite a bit before stabilizing.

The high-level goal of this project is to enable rapid development of adapter services. HTTP and caching concerns should be exposed to a minimal extent so the developer can focus on data transformation.

## Roadmap

* Write tests!
* Granular control over request headers when necessary (api tokens, etc)
* Provide clients with a way to retrieve fresh data
* Respect `Cache-Control` headers
* Allow specific request params to be ignored when building the cache key ([see more](https://github.com/lostisland/faraday_middleware/blob/3a63323d6e1741665ad2ead9b3291bd59e9be0d8/lib/faraday_middleware/response/caching.rb#L27-L29)).
* Additional built in proxy types (XML, HTML, ...)
* Web framework adapters (currently roll-your-own, except for sinatra)
* Handle pagination

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'spy_glass'
```

And then execute:

```console
$ bundle
```

Or install it yourself as:

```console
$ gem install spy_glass
```

## Usage

This example proxy transforms a JSON API payload of San Francisco 311 cases into a GeoJSON feature collection. The transformed response body is cached for 5 minutes.

```ruby
require 'spy_glass'

proxy = SpyGlass.build(:json) do |config|
  config.cache = ActiveSupport::Cache::MemoryStore.new(expires_in: 5.minutes)

  config.define_source_uri do |params|
    uri = URI('https://data.sfgov.org/resource/vw6y-z8j6')
    uri.query = Rack::Utils.build_query(params)
    uri
  end

  config.define_transformation do |collection|
    features = collection.map do |record|
      { 'id' => record['case_id'],
        'properties' => record,
        'type' => 'Feature',
        'geometry' => {
          'type' => 'Point',
          'coordinates' => [
            record['point']['longitude'].to_f,
            record['point']['latitude'].to_f ] } }
    end

    { 'type' => 'FeatureCollection', 'features' => features }
  end
end

require 'sinatra'

get('/sf-311-cases', &proxy)
```

## Contributing

1. Fork it ( http://github.com/codeforamerica/spy_glass/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
