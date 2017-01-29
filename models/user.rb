require "active_record"

class User < ActiveRecord::Base
  has_many :posts, dependent: :destroy

  validates :login, presence: true, uniqueness: true
end