# SpyGlass

SpyGlass is a utility for defining [web content transformation proxies](http://www.w3.org/TR/ct-guidelines/). Be aware that the W3C guideline is not yet fully covered. For instance, `X-Device-*` headers are not yet implemented. The API of this library is likely to change quite a bit before stabilizing.

The high-level goal of this project is to enable rapid development of adapter services. HTTP and caching concerns should be exposed to a minimal extent so the developer can focus on data transformation.

## Roadmap

* Write tests!
* Provide clients with a way to retrieve fresh data
* Respect `Cache-Control` headers
* Web framework adapters (currently roll-your-own, except for sinatra)

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

See the [examples](examples/).

## Contributing

1. Fork it ( http://github.com/codeforamerica/spy_glass/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
