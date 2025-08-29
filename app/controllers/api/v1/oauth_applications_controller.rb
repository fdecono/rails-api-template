module Api
  module V1
    class OauthApplicationsController < ApiController
      skip_before_action :doorkeeper_authorize!, only: [:create]

      def index
        @applications = Doorkeeper::Application.all
        render json: { applications: @applications }
      end

      def show
        @application = Doorkeeper::Application.find(params[:id])
        render json: { application: @application }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Application not found' }, status: :not_found
      end

      def create
        @application = Doorkeeper::Application.new(application_params)

        if @application.save
          render json: { application: @application }, status: :created
        else
          render json: { errors: @application.errors }, status: :unprocessable_entity
        end
      end

      def update
        @application = Doorkeeper::Application.find(params[:id])

        if @application.update(application_params)
          render json: { application: @application }
        else
          render json: { errors: @application.errors }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Application not found' }, status: :not_found
      end

      def destroy
        @application = Doorkeeper::Application.find(params[:id])
        @application.destroy
        head :no_content
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Application not found' }, status: :not_found
      end

      private

      def application_params
        params.require(:oauth_application).permit(:name, :redirect_uri, :scopes)
      end
    end
  end
end
