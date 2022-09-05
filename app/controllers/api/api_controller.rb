class Api::ApiController < ActionController::Base
  protect_from_forgery with: :null_session

  respond_to :json
  before_action :authenticate_user
  before_action :authenticate_user!

  def not_found
    render json: {error: "No record found"}, status: 404
  end

  private

  def authenticate_user
    token = request.headers['Authorization']
    if token.present? && valid_jwt?(token)
      begin
        jwt_payload = JWT.decode(token, ENV['DEVISE_JWT_SECRET_KEY']).first

        @current_user_id = jwt_payload['id']
      rescue JWT::ExpiredSignature, JWT::VerificationError, JWT::DecodeError
        head :unauthorized
      end
    else
      head :unauthorized
    end
  end

  def authenticate_user!(options = {})
    head :unauthorized unless signed_in?
  end

  def current_user
    @current_user ||= super || User.find_by(id: @current_user_id)
  end

  def signed_in?
    @current_user_id.present?
  end

  def valid_jwt?(token)
    JwtDenylist.find_by(jti: token).nil?
  end
end