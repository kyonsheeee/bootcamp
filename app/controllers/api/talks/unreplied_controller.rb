# frozen_string_literal: true

class API::Talks::UnrepliedController < API::BaseController
  def index
    @talks = Talk.unreplied
  end
end