# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def observe(element, function, event)
    code = <<-CODE
      <script type='text/javascript'>
        Event.observe('#{element}', '#{event}', function(element, value) { #{function} })
      </script>
    CODE
  end
  def render_search_results(partial, collection, locals=nil, msg='No results found')
    if collection && collection.empty?
      return content_tag(:tr, content_tag(:td, msg, :colspan=>'99'))
    else
      render :partial=>partial, :collection=>collection, :locals=>locals
    end
  end
end
