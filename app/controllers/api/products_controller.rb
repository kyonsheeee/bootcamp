# frozen_string_literal: true

class API::ProductsController < API::BaseController
  before_action :require_staff_login_for_api, only: :index

  def index
    @company = Company.find(params[:company_id])
    @products = Product
                .list
                .order_for_list
                .page(params[:page])
  end
end
