$: << '../lib'
require_relative '../lib/spy_glass'

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
