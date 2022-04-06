# frozen_string_literal: true

require 'test_helper'

class API::ProductsTest < ActionDispatch::IntegrationTest
  test 'GET /api/products.json' do
    get api_products_path(format: :json)
    assert_response :unauthorized

    token = create_token('mentormentaro', 'testtest')
    get api_products_path(format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end

  test 'GET /api/products/unchecked.json' do
    get api_products_unchecked_index_path(format: :json)
    assert_response :unauthorized

    token = create_token('kimura', 'testtest')
    get api_products_unchecked_index_path(format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :unauthorized

    token = create_token('mentormentaro', 'testtest')
    get api_products_unchecked_index_path(format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end

  test 'GET /api/products/self_assigned.json' do
    get api_products_self_assigned_index_path(format: :json)
    assert_response :unauthorized

    token = create_token('kimura', 'testtest')
    get api_products_self_assigned_index_path(format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :unauthorized

    token = create_token('mentormentaro', 'testtest')
    get api_products_self_assigned_index_path(format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end

  test 'GET /api/products.json?company_id=362477616' do
    company = companies(:company4)
    get api_products_path(company_id: company.id, format: :json)
    assert_response :unauthorized

    token = create_token('kimura', 'testtest')
    get api_products_path(company_id: company.id, format: :json),
        headers: { 'Authorization' => "Bearer #{token}" }
    assert_response :ok
  end
end
