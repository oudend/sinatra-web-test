require 'active_support/inflector'
require 'cells'

class FruitCardCell < Cell::ViewModel
  include ::Cell::Erb

  self.view_paths = ["cells/"]

  def time_ago_in_words(time)
    seconds_ago = Time.now - time

    minutes = (seconds_ago / 60).to_i
    hours = (seconds_ago / (60 * 60)).to_i
    days = (seconds_ago / (60 * 60 * 24)).to_i
    months = (seconds_ago / (60 * 60 * 24 * 30)).to_i
    years = (seconds_ago / (60 * 60 * 24 * 365)).to_i

    if years > 0
        "#{years} #{'year'.pluralize(years)} ago"
    elsif months > 0
        "#{months} #{'month'.pluralize(months)} ago"
    elsif days > 0
        "#{days} #{'day'.pluralize(days)} ago"
    elsif hours > 0
        "#{hours} #{'hour'.pluralize(hours)} ago"
    elsif minutes > 0
        "#{minutes} #{'minute'.pluralize(minutes)} ago"
    else
        "just now"
    end
  end

  def show(fruit_data, t)
    @t = t

    @fruit_data = fruit_data

    @edited_at = "at the beginning of time"
    
    if fruit_data['edited_at'] != nil
        @edited_at = time_ago_in_words(Time.parse(fruit_data['edited_at']))
    end


    render :show
  end
end
