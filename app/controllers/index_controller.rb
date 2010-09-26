class IndexController < ApplicationController
  def index
    render :layout=>'application' end

  def failure
    flash[:notice] = "Application Error"
    render :action=>:failure, :layout=>'application', :status=>500
  end
  
  def user
    @focus_user = User.by_screen_name(params[:user]).first
    unless @focus_user
      flash[:notice] = "No such User or Page"
      return render :status=>404, :action=>'failure', :layout=>'application'
    end
    
    respond_to do |format|
      format.html
      format.xml  { render :text=>user_feed.to_s }
    end
  end

  private
  def user_feed
    RSS::Maker.make('1.0') do |maker|
      maker.channel.about = URI.join("http://rsss.be", user_feed_path(@focus_user.screen_name))
      maker.channel.title = ['RSSS | ', @focus_user.screen_name].join
      maker.channel.description = @focus_user.description
      maker.channel.link = URI.join("http://rsss.be", user_page_path(@focus_user.screen_name))
      maker.channel.author = @focus_user.screen_name
      maker.channel.date = @focus_user.updated_at
      maker.items.do_sort = true

      @focus_user.recent_entries.each do |entry|
        maker.items.new_item do |item|
          item.link = entry.link
          item.title = entry.title
          item.date = entry.date
          item.description = entry.content
        end
      end
    end
  end

end
