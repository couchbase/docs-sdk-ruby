# tag::imports[]
require "couchbase"
# end::imports[]

# tag::connect[]
# Update these credentials for your Capella instance!
options = Cluster::Options::Cluster.new
options.authenticate("username", "Password!123")

# Sets a pre-configured profile called "wan-development" to help avoid latency issues
# when accessing Capella from a different Wide Area Network
# or Availability Zone (e.g. your laptop).
options.apply_profile("wan_development")

cluster = Cluster.connect("couchbases://cb.<your-endpoint>.cloud.couchbase.com", options)
# end::connect[]

# tag::bucket[]
# get a bucket reference
bucket = cluster.bucket("travel-sample")
#end::bucket[]

# tag::collection[]
# get a user-defined collection reference
scope = bucket.scope("tenant_agent_00")
collection = scope.collection("users")
# end::collection[]

# tag::upsert-get[]
# Upsert Document
upsert_result = collection.upsert(
  "my-document-key",
  {
    "name" => "Ted",
    "age" => 31
  }
)
p cas: upsert_result.cas
#=> {:cas=>223322674373654}

# Get Document
get_result = collection.get("my-document-key")
p cas: get_result.cas,
  name: get_result.content["name"]
#=> {:cas=>223322674373654, :name=>"Ted"}
# end::upsert-get[]

# tag::n1ql-query[]
inventory_scope = bucket.scope("inventory")
result = inventory_scope.query('SELECT * FROM airline WHERE id = 10;')
result.rows.each do |row|
  p row
end
# end::n1ql-query[]

# tag::disconnect[]
cluster.disconnect
# end::disconnect[]
