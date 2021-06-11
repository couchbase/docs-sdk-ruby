require "couchbase"
include Couchbase # rubocop:disable Style/MixinUsage for brevity


def main
    options = Cluster::ClusterOptions.new
    options.authenticate("Administrator", "password")
    cluster = Cluster.connect("couchbase://localhost", options)
    users = cluster.users

    puts "scopeAdmin"
    # tag::scopeAdmin[]
    user = Management::User.new {|user|
        user.username = "scope_admin"
        user.password = "password"
        user.display_name = "Manage Scopes [travel-sample:*]"
        user.roles = [
            Management::Role.new {|role|
                role.name = "scope_admin"
                role.bucket = "travel-sample"},
            Management::Role.new {|role|
                role.name = "data_reader"
                role.bucket = "travel-sample"}
            ]
    }
    users.upsert_user(user)
    # end::scopeAdmin[]

    puts "create-collection-manager"
    # tag::create-collection-manager[]
    options = Cluster::ClusterOptions.new
    options.authenticate("scope_admin", "password")
    cluster = Cluster.connect("couchbase://localhost", options)
    bucket = cluster.bucket("travel-sample")
    collections = bucket.collections
    # end::create-collection-manager[]

    # tag::create-scope[]
    scopes = collections.get_all_scopes

    if scopes.any? { |scope| scope.name == "example-scope" }
    puts "Scope already exists"
    else
        collections.create_scope("example-scope")
    end
    # end::create-scope[]

    puts "create-collection"
    # tag::create-collection[]
    collection = Management::CollectionSpec.new {|spec|
        spec.name = "example-collection"
        spec.scope_name = "example-scope" }

    collections.create_collection(collection)
    # end::create-collection[]

    puts "drop-collection"
    # tag::drop-collection[]
    collections.drop_collection(collection)
    # end::drop-collection[]

    puts "drop-scope"
    # tag::drop-scope[]
    collections.drop_scope("example-scope")
    # end::drop-scope[]
end

main()