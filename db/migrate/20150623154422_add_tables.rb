class AddTables < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :slack_handle
      t.string :venmo_handle
    end

    create_table :locations do |t|
      t.string :name
      t.string :website
      t.string :phone_number
      t.string :menu_url
    end

    create_table :plans do |t|
      t.integer  :location_id
      t.datetime :eta_at
      t.integer  :user_id
      t.float    :total
    end

    create_table :plan_users do |t|
      t.integer :plan_id
      t.integer :location_id
      t.text    :order
    end
  end
end
