class LoginController < Doorkeeper::TokensController
  def create
    addtl = { client_id: client_uid, client_secret: client_secret }
    user = User.find_by(email: params[:email])
    if user&.is_admin
      addtl.merge!({ scope: 'admin' })
    end
    self.request.params.merge!(addtl)
    if user&.deactivated
      render json: { error_description: "User has been deactivated. Please contact admin" }, status: :forbidden
    else 
     super
    end
  end

  private

  def client_uid
    Doorkeeper::Application.find_by(name: 'Web').uid
  end

  def client_secret
    Doorkeeper::Application.find_by(name: 'Web').secret
  end
end
