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

  def generate_password_token!
    self.reset_password_token = generate_jwt
    self.reset_password_sent_at = Time.now.utc
    save!
  end

  def password_token_valid?
    (self.reset_password_sent_at + 4.hours) > Time.now.utc
  end

  def reset_password!(password)
    self.reset_password_token = nil
    self.password = password
    save!
  end
end
