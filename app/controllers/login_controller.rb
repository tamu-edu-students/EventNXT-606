class LoginController < Doorkeeper::TokensController
  def create
    addtl = { client_id: client_uid, client_secret: client_secret }
    if User.find_by(email: params[:email])&.is_admin
      addtl.merge!({ scope: 'admin' })
    end
    self.request.params.merge!(addtl)
    super
  end

  private

  def client_uid
    Doorkeeper::Application.find_by(name: 'Web').uid
  end

  def client_secret
    Doorkeeper::Application.find_by(name: 'Web').secret
  end

  def create_success
    flash[:notice] = "Successfully logged in"
    redirect_to events_path # Redirect to the "/events" route
  end
end
