class CreateContentsCoreItems < ActiveRecord::Migration[5.0]
  def change
    create_table :contents_core_items do |t|
      t.string     :type
      t.string     :name, null: false, default: 'data'
      t.integer    :block_id
      t.boolean    :data_boolean
      t.datetime   :data_datetime
      t.string     :data_file  # , null: false, default: ''
      t.float      :data_float
      t.text       :data_hash
      t.integer    :data_integer
      t.string     :data_string  # , null: false, default: ''
      t.text       :data_text
      t.timestamps null: false
    end

    add_index :contents_core_items, :block_id
  end
end
