class ClearanceUpdateUsers < ActiveRecord::Migration
  def self.up
    change_table(:users) do |t|
      t.string :encrypted_password, :limit => 128
      t.string :salt, :limit => 128
      t.string :confirmation_token, :limit => 128
      t.string :remember_token, :limit => 128
      t.boolean :email_confirmed, :default => false, :null => false
      t.boolean :admin, :default => false, :null => false
    end

    add_index :users, [:id, :confirmation_token]
    add_index :users, :email
    add_index :users, :remember_token

    User.all.each{|u| u.password = u.security_phrase; u.save!}
  end

  def self.down
    change_table(:users) do |t|
      t.remove :encrypted_password,:salt,:confirmation_token,:remember_token,:email_confirmed, :admin
    end
  end
end
