$: << '../lib'
require_relative '../lib/spy_glass'

proxy = SpyGlass::Proxy.new('https://data.sfgov.org') do |config|
  config.content_type = 'application/json'
  config.define_parser { |body| JSON.parse(body) }
  config.define_generator { |body| JSON.pretty_generate(body) }

  config.cache = ActiveSupport::Cache::MemoryStore.new(expires_in: 5.minutes)

  config.define_transformation do |collection|
    features = collection.map do |record|
      point = record.delete('point')

      { 'type' => 'Feature',
        'id' => record['case_id'],
        'properties' => record,
        'geometry' => {
          'type' => 'Point',
          'coordinates' => [
            point['longitude'].to_f,
            point['latitude'].to_f ] } }
    end

    { 'type' => 'FeatureCollection', 'features' => features }
  end
end

require 'sinatra'

get('*', provides: :json, &proxy)
