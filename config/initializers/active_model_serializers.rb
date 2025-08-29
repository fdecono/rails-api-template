# Configure ActiveModelSerializers
ActiveModelSerializers.config.adapter = :json_api
ActiveModelSerializers.config.key_transform = :camel_lower

# Use default serializer lookup (comment out custom lookup for now)
# ActiveModelSerializers.config.serializer_lookup_chain = [
#   ->(resource_class, _serializer_options = nil) { "#{resource_class.name}Serializer" },
#   ->(resource_class, _serializer_options = nil) { "#{resource_class.superclass.name}Serializer" }
# ]
