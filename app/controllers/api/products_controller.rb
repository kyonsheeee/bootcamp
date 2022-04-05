# frozen_string_literal: true

class API::ProductsController < API::BaseController
  before_action :require_staff_login_for_api, only: :index

  def index
    @products = if params[:id].present?
                  Product.where(id: params[:id])
                else
                  Product
                    .list
                    .order_for_list
                    .page(params[:page])
                end
  end
end
