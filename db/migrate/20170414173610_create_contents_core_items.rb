class CreateContentsCoreItems < ActiveRecord::Migration[5.0]
  def change
    create_table :contents_core_items do |t|
      t.string  :type
      t.string  :name, null: false, default: 'data'
      t.integer :block_id
    end

    add_index :contents_core_items, :block_id
  end
end
