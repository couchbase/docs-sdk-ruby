require 'couchbase'
include Couchbase

options = Cluster::ClusterOptions.new
options.authenticate("Administrator", "fred123")
cluster = Cluster.connect("couchbase://10.143.201.101", options)
bucket = cluster.bucket("test1")
collection = bucket.default_collection

res = collection.upsert("u:king_arthur2", {'name': 'Arthur2', 'email': 'kingarthur2@couchbase.com', 'interests': ['Holier Grails', 'European Swallows']})
p res.cas

res = collection.get("u:king_arthur2")
p res.content
p res.cas

options = Cluster::QueryOptions.new
options.named_parameters({type: "name"})
options.metrics = true
res = cluster.query("SELECT * FROM `test1` WHERE type = $type LIMIT 10", options)
res.rows.each do |row|
  puts "#{row["test1"]}. #{row["test1"]["name"]}"
end

cluster.disconnect
