class AddExtraItems < ActiveRecord::Migration[5.0]
  def change
    add_column :contents_core_items, :data_boolean, :boolean
    add_column :contents_core_items, :data_datetime, :datetime
    add_column :contents_core_items, :data_file, :string  # , null: false, default: ''
    add_column :contents_core_items, :data_float, :float
    add_column :contents_core_items, :data_hash, :string  # , null: false, default: ''
    add_column :contents_core_items, :data_integer, :integer
    add_column :contents_core_items, :data_string, :string  # , null: false, default: ''
    add_column :contents_core_items, :data_text, :text
  end
end
