class Api::V1::ReferralSummaryController < Api::V1::ApiController
  def index
    summary = query.limit(params[:limit]).offset(params[:offset])
    render json: summary, except: [:id]
  end

  private

  def query
    Guest.joins(:guest_referrals)
         .select("guests.email, guests.first_name, guests.last_name, guest_referrals.email as referred_email, guest_referrals.counted as status")
         .where("event_id = :event_id", {event_id: params[:event_id]})
  end
end
