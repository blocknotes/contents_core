class CreateContentsCoreBlocks < ActiveRecord::Migration[5.0]
  def change
    create_table :contents_core_blocks do |t|
      t.string  :block_type, null: false, default: 'text'
      t.integer :version, null: false, default: 0
      t.string  :name, null: false, default: ''
      t.string  :group
      t.integer :position, null: false, default: 0
      t.boolean :published, null: false, default: true
      t.string  :options, null: false, default: '{}'
      t.string  :validations, null: false, default: '{}'
      t.integer :parent_id
      t.string  :parent_type
    end

    add_index :contents_core_blocks, [:parent_id, :parent_type]
  end
end
