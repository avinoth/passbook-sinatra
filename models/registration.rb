class Registration < ActiveRecord::Base
  belongs_to :pass
  belongs_to :device
end
