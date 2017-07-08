def data_attrs( object )
  ret = {label: I18n.t("activerecord.attributes.contents_core/item.#{object.name}")}
  case object.class.to_s
  when 'ContentsCore::ItemFile'
    ret[:hint] = image_tag( object.data.url( :thumb ) )
  when 'ContentsCore::ItemText'
    ret[:as] = :ckeditor
  end
  ret
end

ActiveAdmin.register Page do
  filter :title
  filter :published

  permit_params do
    Page.column_names + [ :cc_blocks ] + [
      cc_blocks_attributes: [
        :id, :name, :block_type, :position, :_destroy, items_attributes: [ :id, :data ],
        cc_blocks_attributes: [
          :id, :name, :block_type, items_attributes: [ :id, :data ]
        ]
      ]
    ]
  end

  controller do
    def create
      super do |format|
        redirect_to edit_resource_url and return if resource.valid?
      end
    end

    def update
      super do |format|
        redirect_to collection_url and return if resource.valid?
      end
    end
  end

  index do
    selectable_column
    id_column
    column :title
    column :slug
    column :published
    column :created_at
    actions
  end

  form do |frm|
    frm.inputs "#{I18n.t('general.form.'+params[:action])} #{frm.object.model_name.human}" do
      frm.input :title
      frm.input :slug unless frm.object.new_record?
      frm.has_many :cc_blocks, heading: false, sortable: :position, sortable_start: 1, new_record: 'New block' do |b|
        b.input :name if b.object.new_record?
        b.input :block_type, label: 'Type of block', hint: 'Save changes to edit the new block fields', collection: ContentsCore::Block.block_types, input_html: { 'data-sel': 'items' + b.object.id.to_s } if b.object.new_record?
        b.has_many :items, heading: b.object.name, new_record: false do |i|
          i.input :data, data_attrs( i.object )
        end unless b.object.new_record?
        b.has_many :cc_blocks, heading: false, new_record: b.object.has_children? do |bb|
          bb.input :name if bb.object.new_record?
          bb.has_many :items, heading: bb.object.name, new_record: false do |bi|
            bi.input :data, data_attrs( bi.object )
          end
        end unless b.object.new_record?
        b.input :_destroy, label: 'Destroy block', required: false, as: :boolean, wrapper_html: { class: 'checkbox-destroy' } unless b.object.new_record?
      end unless frm.object.new_record?
    end
    frm.actions
  end
end
