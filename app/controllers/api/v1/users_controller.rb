class Api::V1::UsersController < Api::V1::ApiController
  def index
    render json: [], status: :forbidden and return unless (current_user && current_user.is_admin)
    users = User.where(deactivated: false).order(is_admin: :desc).limit(params[:limit]).offset(params[:offset])
    render json: users
  end

  def show
    user = User.find(params[:id])
    if user
      render json: user
    else
      render json: user.errors(), status: :not_found
    end
  end

  def update
    user = User.find(params[:id])
    logger.debug(user_params)
    if user.update(user_params)
      render json: user.to_json, status: :ok
    else
      render json: user.errors, status: :unprocessable_entity
    end
  end

  def get_all
    users = User.all
    render json: users
  end
  
  def change_status
    user = User.find(params[:id])
    user.deactivated = !user.deactivated
    user.save
    render json:user
  end

  def destroy
    user = User.find(params[:id])
    user.update_attribute(:deactivated, true)
    head :ok 
  end

  private 
  
  def user_params
    params.permit(:is_admin, :deactivate)
  end
end