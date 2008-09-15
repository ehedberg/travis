# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def observe(element, function, event)
    code = <<-CODE
      <script type='text/javascript'>
        Event.observe('#{element}', '#{event}', function(element, value) { #{function} })
      </script>
    CODE
  end
end
