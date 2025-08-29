class CollectionRenderer < Renderer
  private

  def render_successful_response
    json_response = response
    json_response = response.merge pagination_data if should_include_pagination_data?
    json_response
  end

  def object_serialization
    @object.map { |object| object.serialize object_serialization_options }
  end

  def should_include_pagination_data?
    @options[:paginated]
  end

  def object_serialization_options
    @options.slice :include, :fields, :serializer
  end

  def pagination_data
    {
      pagination: {
        current: @object.current_page,
        pages: @object.total_pages,
        first_page: @object.first_page?,
        last_page: @object.last_page?
      }
    }
  end

  def collection_serialization_error
    serialization_error "Object must be a collection"
  end

  def validate
    super
    validate_collection
    validate_pagination
  end

  def validate_collection
    raise collection_serialization_error unless is_a_collection?
  end

  def validate_pagination
    fail "Collection must be paginable" if should_include_pagination_data? && collection_is_not_paginable?
  end

  def collection_is_not_paginable?
    not @object.respond_to? :current_page
  end
end
