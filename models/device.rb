class Device < ActiveRecord::Base
  validates_uniqueness_of :device_identifier
  validates_uniqueness_of :push_token

  has_many :registrations
  has_many :passes, through: :registrations
end
