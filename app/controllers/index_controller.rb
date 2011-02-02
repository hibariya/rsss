# -*- encoding: utf-8 -*-

class IndexController < ApplicationController
  def index
    render :layout=>'application' end
 
  #
  # プロダクトのアップデートをリアルタイム表示
  #
  def updates
    @entries = Rsss::Rss.get('https://github.com/hibariya/rsss/commits/master.atom').
      items.map{|item| Rsss::Rss::Entry.new(item) } rescue []
    render :layout=>'application'
  end

  def failure
    flash[:notice] = "Application Error"
    render :action=>:failure, :layout=>'application', :status=>500
  end

  def user
    @focus_user = UserPresenter.load params[:user]
    unless @focus_user
      flash[:notice] = "ユーザまたはページが見つかりませんでした"
      respond_to do |format|
        format.html{ return render :status=>404, :action=>:failure, :layout=>'application' }
        format.xml{ return render :status=>404, :action=>:failure, :layout=>false }
      end
    end
    
    respond_to do |format|
      format.html
      format.xml  { render :text=>user_feed.to_s }
    end
  end

  def category
    @focus_user = User.by_screen_name(params[:user]).first
    unless @focus_user
      flash[:notice] = "ユーザまたはページが見つかりませんでした"
      respond_to do |format|
        format.html{ return render :status=>404, :action=>:failure, :layout=>'application' }
        format.xml{ return render :status=>404, :action=>:failure, :layout=>false }
      end
    end
    
    respond_to do |format|
      category = params[:category].downcase
      format.html { 
        @category_entries = @focus_user.recent_entries.
          select{|entry| entry.categories.map(&:downcase).include? category }
      }
      format.xml { render :text=>category_feed(category).to_s }
    end
  end

  private
  def user_feed
    RSS::Maker.make('1.0') do |maker|
      maker.channel.about = URI.join("http://rsss.be", user_feed_path(@focus_user.screen_name))
      maker.channel.title = ['RSSS | ', @focus_user.screen_name].join
      maker.channel.description =  ['RSSS Feed: ', @focus_user.screen_name, " ", @focus_user.description].join
      maker.channel.link = URI.join("http://rsss.be", user_page_path(@focus_user.screen_name))
      maker.channel.author = @focus_user.screen_name
      maker.channel.date = @focus_user.updated_at || Time.now
      maker.items.do_sort = true

      if @focus_user.recent_entries.empty?
        maker.items.new_item do |item| 
          item.title = 'Created'
          item.link = maker.channel.link
          item.date = maker.channel.date
        end
      else
        @focus_user.recent_entries[0..99].each do |entry|
          maker.items.new_item do |item|
            item.link = entry.link
            item.title = entry.title
            item.date = entry.date
            item.description = entry.content
            entry.categories.each do |category|
              item.dc_subjects.new_subject do |c|
                c.content = category
              end
            end
          end
        end
      end
    end
  end

  def category_feed(category)
    RSS::Maker.make('1.0') do |maker|
      maker.channel.about = URI.join("http://rsss.be", user_feed_path(@focus_user.screen_name), "/#{category}.xml")
      maker.channel.title = ['RSSS | ', @focus_user.screen_name, ' | ', category].join
      maker.channel.description =  ['RSSS Feed: ', @focus_user.screen_name, " ", @focus_user.description].join
      maker.channel.link = URI.join("http://rsss.be", user_feed_path(@focus_user.screen_name), "/#{category}")
      maker.channel.author = @focus_user.screen_name
      maker.channel.date = @focus_user.updated_at || Time.now
      maker.items.do_sort = true

      category_entries = @focus_user.recent_entries.select{|r| r.categories.map(&:downcase).include? category }[0..99]
      if category_entries.empty?
        maker.items.new_item do |item| 
          item.title = 'Created'
          item.link = maker.channel.link
          item.date = maker.channel.date
        end
      else
        category_entries.each do |entry|
          maker.items.new_item do |item|
            item.link = entry.link
            item.title = entry.title
            item.date = entry.date
            item.description = entry.content
            entry.categories.each do |category|
              item.dc_subjects.new_subject do |c|
                c.content = category
              end
            end
          end
        end
      end
    end
  end

end
