class Location < ActiveRecord::Base
  has_many :plans

  def to_short_slack_s
    "*#{name}* (#{identifier})"
  end
end
