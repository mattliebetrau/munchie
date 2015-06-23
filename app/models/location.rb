class Location < ActiveRecord::Base
  has_many :plans

  def to_slack_s
    "#{name} (`#{identifier}`)"
  end
end
