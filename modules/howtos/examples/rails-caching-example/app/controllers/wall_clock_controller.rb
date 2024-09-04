# tag::cache_time_for_3_seconds[]
class WallClockController < ApplicationController
  def now
    @current_time = Rails.cache.fetch("current_time", expires_in: 3.seconds) do
      Time.now
    end
  end
  # end::cache_time_for_3_seconds[]

  private

  before_action :fetch_cached_document

  # This method fetches the representation of the cache entry as it is stored in
  # Couchbase
  def fetch_cached_document
    require "pp"

    @cache_entry = cache_collection.get(
      "current_time",
      Couchbase::Options::Get(transcoder: nil, with_expiry: true))
  rescue Couchbase::Error::DocumentNotFound
  end

  def cache_collection
    @collection ||=
      begin
        type, options = Rails.application.config.cache_store
        if type != :couchbase_store
          raise "Unexpected cache store configured: #{type}"
        end

        cluster = Couchbase::Cluster.connect(
          options[:connection_string],
          options[:username],
          options[:password]
        )
        cluster
          .bucket(options[:bucket])
          .scope(options[:scope])
          .collection(options[:collection])
      end
  end
end
