class PurchasesController < ApplicationController
  def show
    @event_id = params[:event_id]
    @token = params[:token]
<<<<<<< HEAD
=======
    @referee = params[:referee]
>>>>>>> VB-referral
    if params.has_key? :token
      render
    else
      render_not_found
    end
  end
end
