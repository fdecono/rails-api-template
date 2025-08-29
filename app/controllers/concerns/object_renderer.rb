class ObjectRenderer < Renderer
  private

  def render_successful_response
    response
  end

  def object_serialization
    object.serialize @options
  end

  def object_serialization_error
    serialization_error "Object must not be a collection"
  end

  def validate
    super
    raise object_serialization_error if is_a_collection?
  end

  def object
    @object
  end
end
