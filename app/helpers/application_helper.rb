module ApplicationHelper
  def page_title(title = '')
    base_title = 'お米日和'
    title.present? ? "#{base_title} | #{title}".html_safe : base_title
  end
end
