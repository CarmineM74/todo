class User < ActiveRecord::Base
  has_secure_password
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :auth_token, uniqueness: true, allow_blank: true, allow_nil: true

  has_many :projects

  def ensure_auth_token
    self.auth_token = generate_auth_token!
  end

  def clear_auth_token!
    self.auth_token = nil
    save
  end

private

  def generate_auth_token!
    loop do
      token = Digest::SHA1.hexdigest([Time.now,rand].join)
      break token unless User.find_by_auth_token(token)
    end
  end

end
