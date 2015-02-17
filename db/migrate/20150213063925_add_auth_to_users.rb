class AddAuthToUsers < ActiveRecord::Migration
  def change
    add_column :users, :access_token, :string
    add_column :users, :refresh_token, :string
    add_column :users, :expires_at, :datetime
    add_column :users, :gender, :string
    add_column :users, :google_id, :string
    add_column :users, :photo, :string

    add_index :users, :access_token
  end
end
