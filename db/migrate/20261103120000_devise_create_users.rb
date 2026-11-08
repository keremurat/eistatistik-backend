class DeviseCreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email, null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      t.string :reset_password_token
      t.datetime :reset_password_sent_at

      t.datetime :remember_created_at

      t.string :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string :unconfirmed_email

      t.integer :failed_attempts, null: false, default: 0
      t.string :unlock_token
      t.datetime :locked_at

      t.integer :sign_in_count, null: false, default: 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.inet :current_sign_in_ip
      t.inet :last_sign_in_ip

      t.timestamps
    end

    add_index :users, "lower(email)", unique: true, name: "index_users_on_lower_email"
    add_index :users, :reset_password_token, unique: true
    add_index :users, :confirmation_token, unique: true
    add_index :users, :unlock_token, unique: true
  end
end
