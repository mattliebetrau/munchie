class RemoveColumn < ActiveRecord::Migration
  def change
    remove_column :plan_users, :location_id
  end
end
