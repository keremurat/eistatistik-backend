class AddRoleToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :role, :string, null: false, default: "musteri"
    add_check_constraint :users, "role IN ('musteri', 'analizor', 'asistan', 'editor', 'admin')", name: "users_role_check"
  end
end
