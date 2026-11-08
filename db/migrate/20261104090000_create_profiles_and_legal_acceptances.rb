class CreateProfilesAndLegalAcceptances < ActiveRecord::Migration[8.1]
  def change
    create_table :profiles do |t|
      t.references :user, null: false, index: { unique: true }, foreign_key: { on_delete: :cascade }
      t.string :first_name, null: false
      t.string :last_name, null: false

      t.timestamps
    end

    create_table :legal_acceptances do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.string :document_key, null: false
      t.string :document_version, null: false
      t.datetime :accepted_at, null: false
      t.inet :ip_address
      t.string :user_agent, limit: 512

      t.timestamps
    end

    add_index :legal_acceptances,
      [ :user_id, :document_key, :document_version ],
      unique: true,
      name: "index_legal_acceptances_on_user_document_version"

    add_check_constraint :legal_acceptances,
      "document_key IN ('membership_terms', 'kvkk_notice')",
      name: "legal_acceptances_document_key_check"
  end
end
