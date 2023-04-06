class PurchasesController < ApplicationController
  def show
    @event_id = params[:event_id]
    @token = params[:token]
    @referee = params[:referee]
    if params.has_key? :token
      render
    else
      render_not_found
    end
  end
end
