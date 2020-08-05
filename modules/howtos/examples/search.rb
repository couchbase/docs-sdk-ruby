# tag::imports[]
require "couchbase"
include Couchbase # to avoid repeating module name
# end::imports[]

options = Cluster::ClusterOptions.new
options.authenticate("Administrator", "password")
cluster = Cluster.connect("couchbase://localhost", options)

# tag::index[]
search_indexes = cluster.search_indexes.get_all_indexes
unless search_indexes.any? {|idx| idx.name == "my-index-name"}
  index = Management::SearchIndex.new
  index.type = "fulltext-index"
  index.name = "my-index-name"
  index.source_type = "couchbase"
  index.source_name = "beer-sample"
  index.params = {
      mapping: {
          default_datetime_parser: "dateTimeOptional",
          types: {
              "beer" => {
                  properties: {
                      "abv" => {
                          fields: [
                              {
                                  name: "abv",
                                  type: "number",
                                  include_in_all: true,
                                  index: true,
                                  store: true,
                                  docvalues: true,
                              }
                          ]
                      },
                      "category" => {
                          fields: [
                              {
                                  name: "category",
                                  type: "text",
                                  include_in_all: true,
                                  include_term_vectors: true,
                                  index: true,
                                  store: true,
                                  docvalues: true,
                              }
                          ]
                      },
                      "description" => {
                          fields: [
                              {
                                  name: "description",
                                  type: "text",
                                  include_in_all: true,
                                  include_term_vectors: true,
                                  index: true,
                                  store: true,
                                  docvalues: true,
                              }
                          ]
                      },
                      "name" => {
                          fields: [
                              {
                                  name: "name",
                                  type: "text",
                                  include_in_all: true,
                                  include_term_vectors: true,
                                  index: true,
                                  store: true,
                                  docvalues: true,
                              }
                          ]
                      },
                      "style" => {
                          fields: [
                              {
                                  name: "style",
                                  type: "text",
                                  include_in_all: true,
                                  include_term_vectors: true,
                                  index: true,
                                  store: true,
                                  docvalues: true,
                              }
                          ]
                      },
                      "updated" => {
                          fields: [
                              {
                                  name: "updated",
                                  type: "datetime",
                                  include_in_all: true,
                                  index: true,
                                  store: true,
                                  docvalues: true,
                              }
                          ]
                      },
                  }
              }
          }
      }
  }
  cluster.search_indexes.upsert_index(index)
  num_indexed = 0
  loop do
    sleep(1)
    num = cluster.search_indexes.get_indexed_documents_count(index.name)
    break if num_indexed == num
    num_indexed = num
    puts "#{index.name.inspect} indexed #{num_indexed}"
  end
end
# end::index[]

# tag::simple[]
result = cluster.search_query(
    "my-index-name",
    Cluster::SearchQuery.query_string("hop beer")
)
result.rows.each do |row|
  puts "id: #{row.id}, score: #{row.score}"
end
#=>
# id: great_divide_brewing-fresh_hop_pale_ale, score: 0.8361701974709099
# id: left_coast_brewing-hop_juice_double_ipa, score: 0.7902867513072585
# ...

puts "Reported total rows: #{result.meta_data.metrics.total_rows}"
#=> Reported total rows: 6043
# end::simple[]

# tag::query_fields[]
options = Cluster::SearchOptions.new
options.fields = ["name"]
result = cluster.search_query(
    "my-index-name",
    Cluster::SearchQuery.match_phrase("hop beer"),
    options
)
result.rows.each do |row|
  puts "id: #{row.id}, score: #{row.score}\n  fields: #{row.fields}"
end
#=>
# id: deschutes_brewery-hop_henge_imperial_ipa, score: 0.7752384807123055
#   fields: {"name"=>"Hop Henge Imperial IPA"}
# id: harpoon_brewery_boston-glacier_harvest_09_wet_hop_100_barrel_series_28, score: 0.6862594775775723
#   fields: {"name"=>"Glacier Harvest '09 Wet Hop (100 Barrel Series #28)"}

puts "Reported total rows: #{result.meta_data.metrics.total_rows}"
# Reported total rows: 2
# end::query_fields[]

# tag::limit[]
options = Cluster::SearchOptions.new
options.skip = 4
options.limit = 3
result = cluster.search_query(
    "my-index-name",
    Cluster::SearchQuery.query_string("hop beer"),
    options
)
result.rows.each do |row|
  puts "id: #{row.id}, score: #{row.score}"
end
#=>
# id: harpoon_brewery_boston-glacier_harvest_09_wet_hop_100_barrel_series_28, score: 0.6862594775775723
# id: lift_bridge_brewery-harvestor_fresh_hop_ale, score: 0.6674211556164669
# id: southern_tier_brewing_co-hop_sun, score: 0.6630296619927506

puts "Reported total rows: #{result.meta_data.metrics.total_rows}"
# Reported total rows: 6043
# end::limit[]

collection = cluster.bucket("beer-sample").default_collection
# tag::consistency[]
random_value = rand
result = collection.upsert("cool-beer-#{random_value}", {
    "type" => "beer",
    "name" => "Random Beer ##{random_value}",
    "description" => "The beer full of randomness"
})
mutation_state = MutationState.new(result.mutation_token)

options = Cluster::SearchOptions.new
options.fields = ["name"]
options.consistent_with(mutation_state)
result = cluster.search_query(
    "my-index-name",
    Cluster::SearchQuery.match_phrase("randomness"),
    options
)
result.rows.each do |row|
  puts "id: #{row.id}, score: #{row.score}\n  fields: #{row.fields}"
end
#=>
# id: cool-beer-0.4332638785378332, score: 2.6573492057051666
#   fields: {"name"=>"Random Beer #0.4332638785378332"}

puts "Reported total rows: #{result.meta_data.metrics.total_rows}"
# Reported total rows: 1
# end::consistency[]

# tag::highlight[]
options = Cluster::SearchOptions.new
options.highlight_style = :html
options.highlight_fields = ["description"]
result = cluster.search_query(
    "my-index-name",
    Cluster::SearchQuery.match_phrase("banana"),
    options
)
result.rows.each do |row|
  puts "id: #{row.id}, score: #{row.score}"
  row.fragments.each do |field, excerpts|
    puts "  #{field}: "
    excerpts.each do |excerpt|
      puts "  * #{excerpt}"
    end
  end
end
#=>
# id: wells_and_youngs_brewing_company_ltd-wells_banana_bread_beer, score: 0.8269933841266812
# description:
#     * A silky, crisp, and rich amber-colored ale with a fluffy head and strong <mark>banana</mark> note on the nose.
# ...

puts "Reported total rows: #{result.meta_data.metrics.total_rows}"
# Reported total rows: 41
# end::highlight[]

# tag::sort[]
options = Cluster::SearchOptions.new
options.sort = [
    Cluster::SearchSort.score,
    Cluster::SearchSort.field("name"),
]
cluster.search_query(
    "my-index-name",
    Cluster::SearchQuery.match_phrase("hop beer"),
    options
)
# end::sort[]

# bigger example at https://github.com/couchbase/couchbase-ruby-client/blob/master/examples/search.rb
# tag::facet[]
options = Cluster::SearchOptions.new
categories_facet = Cluster::SearchFacet.term("category")
categories_facet.size = 5
options.facets = {"categories" => categories_facet}
cluster.search_query(
    "my-index-name",
    Cluster::SearchQuery.query_string("hop beer"),
    options
)
# end::facet[]
