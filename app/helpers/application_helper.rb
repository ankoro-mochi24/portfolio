module ApplicationHelper
  def page_title(title = '')
    base_title = '白米ランド'
    title.present? ? "#{base_title} | #{title}" : base_title
  end
end