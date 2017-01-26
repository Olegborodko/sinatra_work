require 'test_helper'

# https://github.com/rails/rails/blob/4-2-stable/actionpack/lib/action_dispatch/testing/integration.rb
# rubocop:disable Style/ClassAndModuleChildren:
class ActionController::Serialization::HttpCacheTest < ActionController::TestCase
  # class ActionController::Serialization::HttpCacheTest < ActionDispatch::IntegrationTest
  class HttpCacheTestController < ActionController::Base
    class Model < ActiveModelSerializers::Model
      attr_accessor :name, :description, :comments
    end
    class ModelSerializer < ActiveModel::Serializer
      attributes :name, :description, :comments
    end

    def render_as_serializable_object
      render serialization_options.merge!(json: model)
    end

    def render_as_json_string
      json = ActiveModelSerializers::SerializableResource.new(model, serialization_options).to_json
      render json: json
    end

    private

    def model
      Model.new(name: 'Name 1', description: 'Description 1', comments: 'Comments 1')
    end

    def serialization_options
      { serializer: ModelSerializer, adapter: :json }
    end
  end

  tests HttpCacheTestController

  DATE          = 'Date'.freeze
  LAST_MODIFIED = 'Last-Modified'.freeze
  ETAG          = 'ETag'.freeze
  CACHE_CONTROL = 'Cache-Control'.freeze
  SPECIAL_KEYS  = Set.new(%w(extras no-cache max-age public must-revalidate))
  def test_render_as_serializable_object
    10.times do
      get :render_as_serializable_object
    end
    p [@response.etag?, @response.last_modified, @response.date, @response.headers[CACHE_CONTROL], @response.headers[ETAG], @response.headers[LAST_MODIFIED], @response.headers[DATE]]
  end

  def test_render_as_json_string
    10.times do
      get :render_as_json_string
    end
    p [@response.etag?, @response.last_modified, @response.date, @response.headers[CACHE_CONTROL], @response.headers[ETAG], @response.headers[LAST_MODIFIED], @response.headers[DATE]]
  end
end
# rubocop:enable Style/ClassAndModuleChildren:
