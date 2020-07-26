# tag::imports[]
require "couchbase"
include Couchbase # to avoid repeating module name
# end::imports[]

options = Cluster::ClusterOptions.new
options.authenticate("Administrator", "password")
cluster = Cluster.connect("couchbase://localhost", options)

options = Management::AnalyticsIndexManager::CreateDatasetOptions.new
options.ignore_if_exists = true
options.condition = '`type` = "airport"'
cluster.analytics_indexes.create_dataset("airports", "travel-sample", options)
cluster.analytics_indexes.connect_link

# tag::simple[]
result = cluster.analytics_query('SELECT "hello" AS greeting')
result.rows.each do |row|
  puts row
  #=> {"greeting"=>"hello"}
end
puts "Reported execution time: #{result.meta_data.metrics.execution_time}"
#=> Reported execution time: 14.392402ms
# end::simple[]

# tag::named[]
options = Cluster::AnalyticsOptions.new
options.named_parameters("country" => "France")
result = cluster.analytics_query(
  'SELECT COUNT(*) FROM airports WHERE country = $country',
  options)
# end::named[]

# tag::positional[]
options = Cluster::AnalyticsOptions.new
options.positional_parameters(["France"])
result = cluster.analytics_query(
  'SELECT COUNT(*) FROM airports WHERE country = ?',
  options)
# end::positional[]

# tag::scanconsistency[]
options = Cluster::AnalyticsOptions.new
options.scan_consistency = :request_plus
result = cluster.analytics_query(
  'SELECT * FROM airports WHERE country = "France" LIMIT 10',
  options)
# end::scanconsistency[]

# tag::clientcontextid[]
options = Cluster::AnalyticsOptions.new
options.client_context_id = "user-44-#{rand}"
result = cluster.analytics_query(
  'SELECT * FROM airports WHERE country = "France" LIMIT 10',
  options)
puts result.meta_data.client_context_id
#=> user-44-0.9295598007016517
# end::clientcontextid[]

# tag::priority[]
options = Cluster::AnalyticsOptions.new
options.priority = true
result = cluster.analytics_query(
  'SELECT * FROM airports WHERE country = "France" LIMIT 10',
  options)
# end::priority[]

# tag::readonly[]
options = Cluster::AnalyticsOptions.new
options.readonly = true
result = cluster.analytics_query(
  'SELECT * FROM airports WHERE country = "France" LIMIT 10',
  options)
# end::readonly[]

# tag::printmetrics[]
result = cluster.analytics_query("SELECT 1=1")
puts "Execution time: #{result.meta_data.metrics.execution_time}"
# end::printmetrics[]
