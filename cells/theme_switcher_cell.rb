require 'cells'

class ThemeSwitcherCell < Cell::ViewModel
  include ::Cell::Erb

  self.view_paths = ["cells/"]

  def show()
    render
  end
end
