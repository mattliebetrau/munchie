class Plan < ActiveRecord::Base
  scope :active, lambda { where('eta_at > ?', Time.now) }

  belongs_to :location
  belongs_to :user

  has_many :plan_users
  has_many :users, :through => :plan_users

  def to_slack_s
    "#{location.to_short_slack_s} with:\n\n" +

    " * @#{user.slack_handle} (Leader)" +
    users.map {|u| " * @#{u.slack_handle}" }.join("\n")
  end

end
