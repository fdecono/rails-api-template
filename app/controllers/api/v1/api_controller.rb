module Api
  module V1
    class ApiController < ApplicationController
      include ResponseRenderer
      before_action :doorkeeper_authorize!

      def current_user
        @current_user ||= User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
      end

      private
      def page
        params[:page]
      end

      def per_page
        params[:per_page]
      end

      def is_paginated?
        page.present? && per_page.present?
      end
    end
  end
end
