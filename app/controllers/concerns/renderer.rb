class Renderer
  def initialize(object, options = {})
    @object = object
    @options = options
  end

  def render
    validate
    render_successful_response
  end

  private

  def serialization_error(error_message)
    fail error_message
  end

  def is_a_collection?
    @object.is_a?(Array) || @object.respond_to?(:to_ary)
  end

  def render_successful_response
    raise NotImplementedError, "Subclasses must implement render_successful_response"
  end

  def response
    object_serialization
  end

  def object_serialization
    raise NotImplementedError, "Subclasses must implement object_serialization"
  end

  def validate
    fail "Provided object must not be nil" if @object.nil?
  end
end
