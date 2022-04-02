# frozen_string_literal: true

class API::ProductsController < API::BaseController
  before_action :require_staff_login_for_api, only: :index

  def index
    @products = Product
                .list
                .order_for_list
                .page(params[:page])
    @products = @products.joins(:user).where(users: {company_id:params[:company_id]}) if params[:company_id]
  end
end
