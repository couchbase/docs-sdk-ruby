# tag::imports[]
require "couchbase"
include Couchbase # to avoid repeating module name
# end::imports[]

options = Cluster::ClusterOptions.new
options.authenticate("Administrator", "password")
cluster = Cluster.connect("couchbase://localhost", options)

options = Management::QueryIndexManager::CreatePrimaryIndexOptions.new
options.ignore_if_exists = true
cluster.query_indexes.create_primary_index("travel-sample", options)

# tag::simple[]
options = Cluster::QueryOptions.new
options.metrics = true
result = cluster.query('SELECT * FROM `travel-sample` LIMIT 10', options)
result.rows.each do |row|
  puts row
end
#=>
# {"travel-sample"=>{"callsign"=>"MILE-AIR", "country"=>"United States", "iata"=>"Q5", "icao"=>"MLA", "id"=>10, "name"=>"40-Mile Air", "type"=>"airline"}}
# {"travel-sample"=>{"callsign"=>"TXW", "country"=>"United States", "iata"=>"TQ", "icao"=>"TXW", "id"=>10123, "name"=>"Texas Wings", "type"=>"airline"}}
# ...

puts "Reported execution time: #{result.meta_data.metrics.execution_time}"
#=> Reported execution time: 11.377766ms
# end::simple[]

# tag::named[]
options = Cluster::QueryOptions.new
options.named_parameters({"country" => "France"})
result = cluster.query(
    'SELECT COUNT(*) AS airport_count FROM `travel-sample` WHERE type = "airport" AND country = $country',
    options)
puts "Airports in France: #{result.rows.first["airport_count"]}"
#=> Airports in France: 221
# end::named[]

# tag::positional[]
options = Cluster::QueryOptions.new
options.positional_parameters(["France"])
result = cluster.query(
    'SELECT COUNT(*) AS airport_count FROM `travel-sample` WHERE type = "airport" AND country = ?',
    options)
puts "Airports in France: #{result.rows.first["airport_count"]}"
#=> Airports in France: 221
# end::positional[]

# tag::scan-consistency[]
options = Cluster::QueryOptions.new
options.scan_consistency = :request_plus
result = cluster.query(
    'SELECT COUNT(*) AS airport_count FROM `travel-sample` WHERE type = "airport"',
    options)
puts "Airports in the database: #{result.rows.first["airport_count"]}"
#=> Airports in the database: 1968
# end::scan-consistency[]

# tag::client-context-id[]
options = Cluster::QueryOptions.new
options.client_context_id = "user-44-#{rand}"
result = cluster.query(
    'SELECT COUNT(*) AS airport_count FROM `travel-sample` WHERE type = "airport"',
    options)
puts "client_context_id: #{result.meta_data.client_context_id}"
#=> client_context_id: user-44-0.9899233780544747
# end::client-context-id[]

# tag::read-only[]
options = Cluster::QueryOptions.new
options.readonly = true
cluster.query(
    'SELECT COUNT(*) AS airport_count FROM `travel-sample` WHERE type = "airport"',
    options)
# end::read-only[]

# tag::print-metrics[]
options = Cluster::QueryOptions.new
options.metrics = true
result = cluster.query(
    'SELECT COUNT(*) AS airport_count FROM `travel-sample` WHERE type = "airport"',
    options)
puts "Reported execution time: #{result.meta_data.metrics.execution_time}"
#=> Reported execution time: 2.516245ms
# end::print-metrics[]
