# tag::imports[]
require "couchbase"
include Couchbase # to avoid repeating module name
# end::imports[]

options = Cluster::ClusterOptions.new
options.authenticate("Administrator", "password")
cluster = Cluster.connect("couchbase://localhost", options)

# tag::simple[]
bucket = cluster.bucket("beer-sample")

options = Bucket::ViewOptions.new
options.limit = 5
view_result = bucket.view_query("beer", "brewery_beers", options)
view_result.rows.each do |row|
  puts "key: #{row.id}, id: #{row.id}"
end
#=>
# key: 21st_amendment_brewery_cafe, id: 21st_amendment_brewery_cafe
# key: 21st_amendment_brewery_cafe-21a_ipa, id: 21st_amendment_brewery_cafe-21a_ipa
# key: 21st_amendment_brewery_cafe-563_stout, id: 21st_amendment_brewery_cafe-563_stout
# key: 21st_amendment_brewery_cafe-amendment_pale_ale, id: 21st_amendment_brewery_cafe-amendment_pale_ale
# key: 21st_amendment_brewery_cafe-bitter_american, id: 21st_amendment_brewery_cafe-bitter_american

puts "Total rows: #{view_result.meta_data.total_rows}"
#=> Total rows: 7303
# end::simple[]

# tag::dev[]
options = Bucket::ViewOptions.new
options.limit = 5
options.namespace = :development
bucket.view_query("example", "brewery_beers", options)
# end::dev[]

# tag::options[]
options = Bucket::ViewOptions.new
options.limit = 5
options.scan_consistency = :request_plus
bucket.view_query("beer", "brewery_beers", options)
# end::options[]

# tag::meta[]
options = Bucket::ViewOptions.new
options.limit = 5
options.debug = true
view_result = bucket.view_query("beer", "brewery_beers", options)
puts "Total rows: #{view_result.meta_data.total_rows}"
#=> Total rows: 7303
puts "Debug info present: #{view_result.meta_data.debug_info.is_a?(Hash)}"
#=> Debug info present: true
# end::meta[]
