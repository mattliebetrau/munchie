class Location < ActiveRecord::Base
  has_many :plans

  def to_short_slack_s
    s = "*<#{menu_url}|#{name}>* (#{identifier})"
  end
end
