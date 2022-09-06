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

  def forgot
    if params[:email].blank?
      return render json: {error: "Email not present"}
    end

    user = User.find_by(email: params[:email]) 

    if user.present?
      user.generate_password_token! #generate pass token
      render json: {data: user.as_json.merge(token: user.reset_password_token)}, status: :ok
    else
      render json: {error: "Email address not found. Please check and try again."}, status: :not_found
    end
  end 

  def reset
    token = params[:token].to_s
    if params[:email].blank?
      return render json: {error: "Token not present"}
    end
    user = User.find_by(reset_password_token: token)
    if user.present? && user.password_token_valid?
      if user.reset_password!(params[:password])
        render json: {status: :ok}, status: :ok
      else
        render json: {error: user.errors.full_messages}, status: :unprocessable_entity
      end
    else
      render json: {error:  "Link not valid or expired. Try generating a new link."}, status: :not_found
    end
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