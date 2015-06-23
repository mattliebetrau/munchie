class AddPlanUsersUserId < ActiveRecord::Migration
  def change
    add_column :plan_users, :user_id, :integer
  end
end
