require_relative '../lib/spy_glass'
require 'active_support/core_ext'
require 'spy_glass'

proxy = SpyGlass.build(:json) do |config|
  config.cache = ActiveSupport::Cache::MemoryStore.new(expires_in: 5.minutes)

  config.define_source_uri do
    query = {
      '$limit' => 100,
      '$order' => 'opened DESC',
      '$where' => "status = 'open'"
    }

    'https://data.sfgov.org/resource/vw6y-z8j6?'+Rack::Utils.build_query(query)
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

get('/', &proxy)
