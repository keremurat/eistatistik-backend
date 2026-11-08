class CreateRolesAndPermissions < ActiveRecord::Migration[8.1]
  def up
    create_table :roles do |t|
      t.string :key, null: false
      t.string :name, null: false
      t.text :description
      t.boolean :assignable, null: false, default: false
      t.boolean :system_role, null: false, default: false
      t.string :home_path, null: false, default: "/admin"
      t.timestamps
    end
    add_index :roles, :key, unique: true

    create_table :permissions do |t|
      t.string :key, null: false
      t.string :label, null: false
      t.string :category, null: false
      t.timestamps
    end
    add_index :permissions, :key, unique: true

    create_table :role_permissions do |t|
      t.references :role, null: false, foreign_key: true
      t.references :permission, null: false, foreign_key: true
      t.timestamps
    end
    add_index :role_permissions, [ :role_id, :permission_id ], unique: true

    remove_check_constraint :users, name: "users_role_check"
    AccessCatalog.sync!
  end

  def down
    raise ActiveRecord::IrreversibleMigration if User.where.not(role: %w[musteri analizor asistan editor admin]).exists?

    drop_table :role_permissions
    drop_table :permissions
    drop_table :roles
    add_check_constraint :users, "role IN ('musteri', 'analizor', 'asistan', 'editor', 'admin')", name: "users_role_check"
  end
end
