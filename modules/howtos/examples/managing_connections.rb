#tag::simpleconnect[]
options = Couchbase::ClusterOptions.new
options.authenticator = Couchbase::PasswordAuthenticator.new("Administrator", "password")
cluster = Cluster.connect("couchbase://127.0.0.1", options)
bucket = cluster.bucket("travel-sample")
collection = bucket.default_collection

# You can access multiple buckets using the same Cluster object.
another_bucket = cluster.bucket("beer-sample")

# You can access collections other than the default
# if your version of Couchbase Server supports this feature.
customer_a = bucket.scope("customer-a")
widgets = customer_a.collection("widgets")

# For a graceful shutdown, disconnect from the cluster when the program ends.
cluster.disconnect
#end::simpleconnect[]


#tag::multinodeconnect[]
options = Couchbase::ClusterOptions.new
options.authenticator = Couchbase::PasswordAuthenticator.new("Administrator", "password")
cluster = Cluster.connect("couchbase://192.168.56.101,192.168.56.102", options)
#end::multinodeconnect[]

#tag::connectionstringparams[]
options = Couchbase::ClusterOptions.new
options.authenticator = Couchbase::PasswordAuthenticator.new("Administrator", "password")
cluster = Cluster.connect("couchbases://127.0.0.1?enable_dns_srv=false&query_timeout=10000", options)
#end::connectionstringparams[]

#tag::tls[]
options = Couchbase::ClusterOptions.new
options.authenticator = Couchbase::PasswordAuthenticator.new("Administrator", "password")
cluster = Cluster("couchbases://127.0.0.1?trust_certificate=/path/to/certificate.pem", options)
#end::tls[]

#tag::dnssrv[]
options = Couchbase::ClusterOptions.new
options.authenticator = Couchbase::PasswordAuthenticator.new("Administrator", "password")
cluster = Cluster.connect("couchbases://couchbase.example.org?enable_dns_srv=true", options)
#end::dnssrv[]

#tag::explicitports[]
options = Couchbase::ClusterOptions.new
options.authenticator = Couchbase::PasswordAuthenticator.new("Administrator", "password")
cluster = Cluster.connect("couchbase://192.168.42.101:12000,192.168.42.102:12002", options)
#end::explicitports[]
