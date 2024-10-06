require 'cells'

class LoginCell < Cell::ViewModel
  include ::Cell::Erb

  self.view_paths = ["cells/"]

  def login(locale)
    @locale = locale
    @login = true

    render :show
  end

  def signup(locale)
    @locale = locale
    @login = false
    render :show
  end
end
