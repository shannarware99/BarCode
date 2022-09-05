class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  devise :database_authenticatable,
         :jwt_authenticatable,
         :registerable,:recoverable, :rememberable, :validatable,
         jwt_revocation_strategy: JwtDenylist


  def generate_jwt
    JWT.encode({ id: id, exp: 360.minute.from_now.to_i }, ENV['DEVISE_JWT_SECRET_KEY'])
  end
end
