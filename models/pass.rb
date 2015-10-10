class Pass < ActiveRecord::Base
  validates_uniqueness_of :serial_number

  has_many :registrations
  has_many :devices, through: :registrations
end
