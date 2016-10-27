module ApplicationHelper

  def format_errors(object)
    "#{object.errors.messages.values.join(' ')}"
  end
end
