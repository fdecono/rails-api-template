class AddPasswordDigestToUsers < ActiveRecord::Migration[7.1]
  def change
    # Add password_digest field for bcrypt
    add_column :users, :password_digest, :string

    # Remove the old password field (since we're using bcrypt now)
    remove_column :users, :password, :string

    # Add index on password_digest for performance
    add_index :users, :password_digest
  end
end
