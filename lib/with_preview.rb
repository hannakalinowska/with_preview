# WithPreview
module WithPreview
  
  def form_for_with_preview(record_or_name_or_array, *args, &proc)
    raise ArgumentError, "Missing block" unless block_given?
    
    options = args.extract_options!
    
    form_for(record_or_name_or_array, args, &proc) if options[:preview].nil?
    
    preview_label = options[:preview][:preview_label] || 'Preview'
    edit_label = options[:preview][:edit_label] || 'Edit'
    
    case record_or_name_or_array
    when String, Symbol
      object_name = record_or_name_or_array
    when Array
      object = record_or_name_or_array.last
      object_name = ActionController::RecordIdentifier.singular_class_name(object)
      apply_form_for_options!(record_or_name_or_array, options)
      args.unshift object
    else
      object = record_or_name_or_array
      object_name = ActionController::RecordIdentifier.singular_class_name(object)
      apply_form_for_options!([object], options)
      args.unshift object
    end
    
    preview_button = "#{object_name}_preview_button"
    edit_button = "#{object_name}_edit_button"
    preview_container = "#{object_name}_preview"
    edit_container = "#{object_name}_form_with_preview"
    form_id = "#{object_name}_form_id"

    options.reverse_merge!(:html => {:id => form_id})
    form_id = options[:html][:id]

    concat(form_tag(options.delete(:url) || {}, options.delete(:html) || {}))
    concat("<div id=\"#{edit_container}\"")
    fields_for(object_name, *(args << options), &proc)
    
    concat("</div><div id=\"#{preview_container}\"></div>")
    concat(button_to_remote(preview_label, {
      :update => preview_container,
      :url => options[:preview][:action],
      :method => options[:preview][:method] || :post,
      :with => "$('#{form_id}').serialize()",
      :success => update_page do |page|
        page[edit_container].hide
        page[preview_container].show
        page[preview_button].hide
        page[edit_button].show
      end,
    }, {:id => preview_button} ))
    concat(button_to_function(edit_label, :id => edit_button, :style => 'display:none') do |page|
      page[preview_container].hide
      page[edit_container].show
      page[edit_button].hide
      page[preview_button].show
    end )
    concat('</form>')
  end
end