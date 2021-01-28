require "couchbase"
include Couchbase # rubocop:disable Style/MixinUsage for brevity

options = Cluster::ClusterOptions.new
options.authenticate("Administrator", "password")
cluster = Cluster.connect("couchbase://localhost", options)

# tag::create[]
bucket_name = "new_bucket"

settings = Management::BucketSettings.new
settings.name = bucket_name
settings.ram_quota_mb = 100
settings.flush_enabled = true
measure("New bucket #{bucket_name.inspect} created") { cluster.buckets.create_bucket(settings) }
# end::create[]
sleep(1)

# tag::get[]
settings = cluster.buckets.get_bucket(bucket_name)
puts "Bucket #{bucket_name.inspect} settings:"
puts " * healthy?           : #{settings.healthy?}"
puts " * RAM quota          : #{settings.ram_quota_mb}"
puts " * number of replicas : #{settings.num_replicas}"
puts " * flush enabled:     : #{settings.flush_enabled}"
puts " * max TTL            : #{settings.max_expiry}"
puts " * compression mode   : #{settings.compression_mode}"
puts " * replica indexes    : #{settings.replica_indexes}"
puts " * eviction policy    : #{settings.eviction_policy}"

measure("Bucket #{bucket_name.inspect} flushed") { cluster.buckets.flush_bucket(bucket_name) }
# end::get[]

cluster.disconnect
