# tag::imports[]
require "couchbase"
include Couchbase # to avoid repeating module name
# end::imports[]

bucket_name = "travel-sample"

# tag::connect[]
options = Cluster::ClusterOptions.new
options.authenticate("Administrator", "password")
cluster = Cluster.connect("couchbase://localhost", options)
# end::connect[]

# tag::bucket[]
# get a bucket reference
bucket = cluster.bucket(bucket_name)
#end::bucket[]

# tag::collection[]
# get a user-defined collection reference
scope = bucket.scope("tenant_agent_00")
collection = scope.collection("users")
# end::collection[]

# tag::upsert-get[]
# Upsert Document
upsert_result = collection.upsert(
  "u:king_arthur",
  {
    "name" => "Arthur",
    "email" => "kingarthur@couchbase.com",
    "interests" => [
      "Holy Grails",
      "African Swallows"
    ]
  }
)
p cas: upsert_result.cas
#=> {:cas=>223322674373654}

# Get Document
get_result = collection.get("u:king_arthur")
p cas: get_result.cas,
  name: get_result.content["name"]
#=> {:cas=>223322674373654, :name=>"Arthur"}
# end::upsert-get[]

# tag::n1ql-query[]
result = cluster.query('SELECT "Hello World" AS greeting')
result.rows.each do |row|
  p row
  #=> {"greeting"=>"Hello World"}
end
# end::n1ql-query[]

# tag::disconnect[]
cluster.disconnect
# end::disconnect[]
