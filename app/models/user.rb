class User < ActiveRecord::Base
  has_many :plan_users
  has_many :plans, :through => :plan_users

  # Plans that the user is going along with
  has_many :lead_plans, :class => Plan

  def to_slack_s
    "@#{slack_handle}"
  end
end
