require 'bundler/setup'
require_relative './benchmarking_support'
require_relative './app'

time = 10
cache_store = ActiveSupport::Cache.lookup_store(:memory_store)
comments = (0..50).map do |i|
  Comment.new(id: i, body: 'ZOMG A COMMENT')
end
author = Author.new(id: 42, first_name: 'Joao', last_name: 'Moura')
model = Post.new(id: 1337, title: 'New Post', blog: nil, body: 'Body', comments: comments, author: author)

define_method :json do
  model.to_json
end
define_method :cached_json do
  parts = []
  parts << 'key_name'
  parts << 'adapter_name'
  cache_key = parts.join('/')
  cache_store.fetch(cache_key) { model.to_json }
end
define_method :ams do
  ActiveModelSerializers::SerializableResource.new(model, adapter: :json, serializer: PostSerializer).as_json
end
define_method :cached_ams do
  ActiveModelSerializers::SerializableResource.new(model, adapter: :json, serializer: CachingPostSerializer).as_json
end
def as_json(serializer_instance, adapter_instance, fields, includes = '*')
  if serializer_instance.respond_to?(:each)
    return serializer_instance.map do |each_serializer|
      as_json(each_serializer, adapter_instance, fields, includes)
    end
  end
  cache_key = serializer_instance.cache_key(adapter_instance)
  include_tree = includes || ActiveModel::Serializer::IncludeTree.from_include_args(includes)
  cache_store = ActiveModelSerializers.config.cache_store
  json = cache_store.fetch(cache_key) do
    serializer_instance.attributes(fields)
  end
  serializer_instance.associations(include_tree).each do |association|
    # FIXME: yields each association twice
    json[association.key] ||= as_json(association.serializer, adapter_instance, [], includes[association.key])
  end
  json
end

define_method :cached_virtual_ams do
  ### OMG
  post_serializer = CachingPostSerializer.new(model)
  adapter_instance = ActiveModelSerializers::Adapter::Attributes.new(post_serializer)
  fields = nil
  includes = ActiveModel::Serializer::IncludeTree.from_include_args('*')
  { post: as_json(post_serializer, adapter_instance, fields, includes) }
  # parts = []
  # parts << 'ams_blog'
  # parts << 'attributes'
  # cache_key = parts.join('/')
  # cache_store.fetch(cache_key) do
  #   include_tree = ActiveModel::Serializer::IncludeTree.from_include_args('*')
  #   post_serializer = CachingPostSerializer.new(model)
  #   json = { post: post_serializer.attributes }
  #   post_serializer.associations(include_tree).each do |association|
  #     # FIXME: yields each association twice
  #     json[:post][association.key] ||=
  #       case association.key
  #       when :comments
  #         cache_store.fetch(%w(ams_comments attributes).join('/')) do
  #           association.serializer.map(&:attributes)
  #         end
  #       when :blog
  #         association.serializer.attributes
  #       when :author
  #         cache_store.fetch(%w(ams_author attributes).join('/')) do
  #           association.serializer.attributes
  #         end
  #       else
  #         fail ArgumentError, "unexpected association #{association}"
  #       end
  #   end
  #   json
  # end
end
puts JSON.pretty_generate(
  equality: { cached_ams: ams == cached_ams, cached_virtual_ams: ams == cached_virtual_ams },
  ams: ams,
  cached_ams: cached_ams,
  cached_virtual_ams: cached_virtual_ams
)

{
  # 'cached json' => { disable_gc: true, send: :cached_json },
  # 'json'        => { disable_gc: true, send: :json },
  # 'cached ams' => { disable_gc: true, send: :cached_ams },
  'cached virtual ams' => { disable_gc: true, send: :cached_virtual_ams },
  'ams' => { disable_gc: true, send: :ams }
}.each do |label, options|
  Benchmark.ams(label, time: time, disable_gc: options[:disable_gc]) do
    send(options[:send])
  end
end
__END__
cached json 121321.3745504354/ips; 16 objects
json 1177.243210850789/ips; 1984 objects
cached ams 251.90341731442047/ips; 5879 objects
cached virtual ams 89169.87612473704/ips; 16 objects
ams 598.9890084759535/ips; 2348 objects
Benchmark results:
{
  "commit_hash": "aa0be94",
  "version": "0.10.0.rc5",
  "rails_version": "4.2.5.1",
  "benchmark_run[environment]": "2.2.3p173",
  "runs": [
    {
      "benchmark_type[category]": "cached json",
      "benchmark_run[result][iterations_per_second]": 121321.375,
      "benchmark_run[result][total_allocated_objects_per_iteration]": 16
    },
    {
      "benchmark_type[category]": "json",
      "benchmark_run[result][iterations_per_second]": 1177.243,
      "benchmark_run[result][total_allocated_objects_per_iteration]": 1984
    },
    {
      "benchmark_type[category]": "cached ams",
      "benchmark_run[result][iterations_per_second]": 251.903,
      "benchmark_run[result][total_allocated_objects_per_iteration]": 5879
    },
    {
      "benchmark_type[category]": "cached virtual ams",
      "benchmark_run[result][iterations_per_second]": 89169.876,
      "benchmark_run[result][total_allocated_objects_per_iteration]": 16
    },
    {
      "benchmark_type[category]": "ams",
      "benchmark_run[result][iterations_per_second]": 598.989,
      "benchmark_run[result][total_allocated_objects_per_iteration]": 2348
    }
  ]
}
