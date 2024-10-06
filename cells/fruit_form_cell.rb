require 'cells'

class FruitFormCell < Cell::ViewModel
  include ::Cell::Erb

  self.view_paths = ["cells/"]

  def edit_fruit(fruit_data, locale)
    @locale = locale
    @fruit_data = fruit_data
    @action_url = "/fruits/change"

    render :show
  end

  def create_fruit(default_name="", default_tastiness=0, default_description="", default_price=0, default_category="", locale)
    @locale = locale
    @fruit_data = {"name" => default_name, "tastiness" => default_tastiness, "description" => default_description, "price" => default_price, "category" => default_category}
    @action_url = "/fruits/new"
    render :show
  end
end
