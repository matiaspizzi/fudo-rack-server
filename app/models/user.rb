require "bcrypt"
require_relative "../db/sequel"


class User < Sequel::Model
  plugin :validation_helpers

  def password=(raw)
    self.password_digest = BCrypt::Password.create(raw)
  end

  def validate
    super
    validates_presence [:username, :password_digest]
    validates_unique :username
  end

  def authenticate(password)
    BCrypt::Password.new(self.password_digest) == password
  end
end
