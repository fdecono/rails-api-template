module ResponseRenderer
  def render_object(object, options = {})
    render_response(hash: ObjectRenderer.new(object, options).render, status: :ok)
  end

  def render_collection(collection, options = {})
    render_response(hash: CollectionRenderer.new(collection, options).render, status: :ok)
  end

  def render_record_invalid_error(exception)
    render_error(
      name: :invalid_record,
      message: exception.record.errors.messages,
      status: :unprocessable_entity
    )
  end

  def render_record_not_found_error(exception)
    render_error(
      name: :record_not_found,
      message: "#{exception.model.constantize.model_name.human} not found",
      status: :not_found
    )
  end

  def render_error(name:, message:, status:)
    hash = { data: { error_name: name, error_message: message }.compact }
    render_response(hash: hash, status: status)
  end

  def render_response(hash:, status:)
    render json: hash, status: status, adapter: :json
  end
end
