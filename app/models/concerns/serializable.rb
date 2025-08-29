module Serializable
  def serialize(options = {})
    # Use the correct ActiveModelSerializers API
    serializer_class = ActiveModel::Serializer.serializer_for(self, options)
    if serializer_class
      serializer = serializer_class.new(self, options)
      ActiveModelSerializers::Adapter.create(serializer).as_json
    else
      # Fallback to basic serialization
      as_json(options)
    end
  end
end
