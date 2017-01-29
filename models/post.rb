require "active_record"

class Post < ActiveRecord::Base
  belongs_to :user

  validates :title, presence: true
  validates :text, presence: true, length: { maximum: 500 }
end