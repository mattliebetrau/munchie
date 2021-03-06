class Plan < ActiveRecord::Base
  scope :active, lambda { where('eta_at > ?', Time.now).where(:total => nil) }

  belongs_to :location
  belongs_to :user

  has_many :plan_users
  has_many :users, :through => :plan_users

  def to_slack_s
    "#{location.to_short_slack_s}. Leaving at #{eta_at} with:\n\n" +

    " * #{user.to_slack_s} (Leader)\n" +
    users.map {|u|
      pu = plan_user_for(u)

      if pu
        " * #{u.to_slack_s}  _\"#{pu.order}\"_"
      else
        " * #{u.to_slack_s}"
      end
    }.join("\n")
  end

  def plan_user_for(user)
    plan_users.where(:user => user).first
  end

end
