class Plan < ActiveRecord::Base
  scope :active, lambda { where('eta_at > ?', Time.now) }

  belongs_to :location
  belongs_to :user
end
