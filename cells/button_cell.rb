require 'cells'

class ButtonCell < Cell::ViewModel
  include ::Cell::Erb

  self.view_paths = ["cells/"]

  def show(label, url)
    @label = label
    @url = url
    render
    # render inline: "<a href='#{url}' class='button'>#{label}</a>"
  end
end
