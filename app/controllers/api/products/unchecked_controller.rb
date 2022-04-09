# frozen_string_literal: true

class API::Products::UncheckedController < API::BaseController
  before_action :require_staff_login_for_api
  def index
    @target = params[:target]
    @target = 'unchecked_all' unless target_allowlist.include?(@target)
    @products = case @target
                when 'unchecked_all'
                # p '*' * 100
                  pp Product.unchecked
                         .not_wip
                         .list
                         .order_for_not_wip_list
                         .page(params[:page])
                when 'unchecked_no_replied'
                  Product.unchecked_no_replied_products(current_user.id)
                         .unchecked
                         .not_wip
                         .list
                         .order_for_not_wip_list
                         .page(params[:page])
                end
                # binding.irb
    @all_submitted_products = @products.group_by { |product| product.elapsed_days >= 7 ? 7 : product.elapsed_days }
    p '*' * 100
    pp @all_submitted_products[0].pluck(:published_at)
  end

  private

  def target_allowlist
    %w[unchecked_all unchecked_no_replied]
  end
end
