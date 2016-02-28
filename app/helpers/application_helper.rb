module ApplicationHelper
  def icon(name, options = {})
    options[:class] = "icon icon_#{name} #{options[:class]}"
    text = options.delete(:text)
    str = content_tag :i, nil, options
    str += " #{text}" if text
    str
  end
end
