class Api::BusinessController < Api::ApiController
  before_action :authenticate_user!

  respond_to :json
  def index
    render json: {msg: "success"}, status: 200
  end

  def show
  end
end
