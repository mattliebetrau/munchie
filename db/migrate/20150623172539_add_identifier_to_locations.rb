class AddIdentifierToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :identifier, :string
  end
end
