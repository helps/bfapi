class User < ActiveRecord::Base

  def self.haskey? key
    User.where(key: key).any?
  end
end
