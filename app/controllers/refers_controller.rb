class RefersController < ApplicationController
  def show
    @event_id = params[:event_id]
    @token = params[:token]
    if params.has_key? :token
      render
    else
      render_not_found
    end
  end
end
