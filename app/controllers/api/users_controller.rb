class Api::UsersController < ActionController::Base
  skip_before_action :verify_authenticity_token
  respond_to :json
  before_action :find_user, only: [:sign_up, :sign_in]

  def sign_up
    return user_already_exists if @user

    @user = User.new(user_params)
    if @user.save
      @current_user = @user
      render sign_in
    else
      render json: { error: @user.errors }, status: 400
    end
  end

  def sign_in
    if @user && @user.valid_password?(params[:user][:password])
      @current_user = @user
    else
      render json: { errors: { 'email or password' => ['is invalid'] } }, status: :unprocessable_entity
    end
  end

  def sign_out
    JwtDenylist.find_or_create_by(jti: request.headers['Authorization'], exp: Time.now) if request.headers['Authorization']
    render json: { message: "signed out" }, status: 201
  end

  private

  def user_params
    params.require(:user).permit(:email, :first_name, :last_name, :password, :password_confirmation, :dob, :phone_number)
  end

  def verify_signed_out_user
  end

  def find_user
    @user = User.find_by(email: params[:user][:email])
  end

  def user_already_exists
    render json: { message: "user already exists" }, status: 400
  end

end