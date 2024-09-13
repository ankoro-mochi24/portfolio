module ApplicationHelper
  def page_title(title = '')
    base_title = 'お米日和'
    title.present? ? "#{base_title} | #{title}" : base_title
  end
end