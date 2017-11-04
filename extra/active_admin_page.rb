module Formtastic
  module Inputs
    class HashInput < Formtastic::Inputs::StringInput
      def to_html
        input_wrapping do
          # label_html <<
          object.keys.map do |key|
            template.content_tag( :div, style: 'clear: both' ) do
              template.label( object.name, ::I18n.t("activerecord.attributes.contents_core/item.#{object.name}.#{key}") ) <<
              field_input( object, key )
            end
          end.join.html_safe
        end
      end

      def field_input( object, key )
        if object.config[:input] == :html
          builder.text_area( method, input_html_options.merge({ id: nil, 'data-hash-key': key, value: object.data[key.to_s] }) )
        else
          builder.text_field( method, input_html_options.merge({ id: nil, 'data-hash-key': key, value: object.data[key.to_s] }) )
        end
      end
    end
  end
end

# ContentsCore::ItemObject.class_eval do
#   def data=( value )
#     self.from_string( value )
#   end
# end

## Add to 'config.after_initialize do' in 'application.rb'
# ContentsCore::ItemFile.class_eval do
#   mount_uploader :data_file, ImageUploader
# end

def data_attrs( object )
  ret = {label: I18n.t("activerecord.attributes.contents_core/item.#{object.name}"), input_html:{'data-cc-class': object.class.to_s}}
  case object.class.to_s
  when 'ContentsCore::ItemArray'
    ret[:as] = object.is_multiple? ? :check_boxes : :select
    ret[:collection] = object.enum
  when 'ContentsCore::ItemBoolean'
    ret[:as] = :boolean
  when 'ContentsCore::ItemDatetime'
    ret[:as] = :date_select # :date_picker
  when 'ContentsCore::ItemFile'
    ret[:hint] = image_tag( object.data.url ) if object.data?
  when 'ContentsCore::ItemFloat', 'ContentsCore::ItemInteger'
    ret[:as] = :number
  when 'ContentsCore::ItemHash'
    ret[:as] = :hash
  when 'ContentsCore::ItemText'
    ret[:as] = :ckeditor
  end
  ret
end

ActiveAdmin.register Page do
  filter :title
  filter :published

  # permit_params do
  #   Page.column_names + [ :cc_blocks ] + [
  #     cc_blocks_attributes: [
  #       :id, :name, :block_type, :position, :_destroy, items_attributes: [ :id, :data ],
  #       cc_blocks_attributes: [
  #         :id, :name, :block_type, items_attributes: [ :id, :data ]
  #       ]
  #     ]
  #   ]
  # end

  controller do
    def create
      super do |format|
        redirect_to edit_resource_url and return if resource.valid?
      end
    end

    def permitted_params
      params.permit!  # TODO: permits all for now
    end

    def save_resource( object )
      if params[:add_block]
        # params[:save_and_edit] = true
        object.create_block params[:add_block].keys[0].to_sym
      else
        run_save_callbacks object do
          object.save
        end
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
      frm.input :author
      frm.input :slug unless frm.object.new_record?

      li class: 'block-buttons' do
        ContentsCore::Block.enum.each do |type|
          frm.button "Crea blocco #{type[0]}", name: "add_block[#{type[1]}]"
        end
      end unless frm.object.new_record?

      frm.has_many :cc_blocks, heading: false, sortable: :position, sortable_start: 1, new_record: false do |b|
        b.input :name if b.object.new_record?
        if b.object.new_record?
          b.input :block_type, label: 'Type of block', hint: 'Save changes to edit the new block fields', collection: ContentsCore::Block.block_enum, input_html: { 'data-sel': 'items' + b.object.id.to_s }
        else
          b.has_many :items, heading: b.object.name, new_record: false do |i|
            i.input :data, data_attrs( i.object )
          end
        end
        b.has_many :cc_blocks, heading: false, new_record: b.object.config[:new_children] do |bb|
          bb.input :name if bb.object.new_record?
          bb.has_many :items, heading: bb.object.name, new_record: false do |bi|
            bi.input :data, data_attrs( bi.object )
          end if bb.object.items.any?
          bb.input :_destroy, label: 'Destroy sub block', required: false, as: :boolean, wrapper_html: { class: 'checkbox-destroy' }
        end if !b.object.new_record? && b.object.config[:new_children]
        b.input :_destroy, label: 'Destroy block', required: false, as: :boolean, wrapper_html: { class: 'checkbox-destroy' } unless b.object.new_record?
      end unless frm.object.new_record?
    end
    frm.actions
  end
end
