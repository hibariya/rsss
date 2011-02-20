# encoding: utf-8

require 'spec_helper'

describe 'User#reload_sites', :clear => true do

  shared_examples_for "RSS parser" do |version|
    let!(:target){ Fabricate :user, :sites => [Fabricate(:site, :failed_at => 1.day.ago)] }
    let!(:failed_at_was){ target.sites.last.failed_at }
    let!(:stub_site){ Fabricate(:example_user).sites.last }
    let!(:stub_entry){ stub_site.entries.first }

    before :all do
      any_instance_of Site do |site|
        stub(site).feed{ Feedzirra::Feed.parse SitePresenter.new(stub_site).feed(version).to_s }
      end
      target.reload_sites
    end

    it "最新のフィードが反映されること" do
      target.sites.each do |site|
        site.title.should     eql stub_site.title
        site.site_uri.should  eql stub_site.site_uri

        site.entries.each do |entry|
          entry.title.should      eql stub_entry.title
          entry.content.should    eql stub_entry.content
          entry.categories.should eql stub_entry.categories
          entry.link.should       eql stub_entry.link
          entry.date.should       eql stub_entry.date
        end
      end
    end

    it "フィードの取得に失敗した日時は更新されていないこと" do
      target.sites.each do |site|
        site.failed_at.should eql failed_at_was
      end
    end
  end

  it_should_behave_like 'RSS parser', '0.9'
  it_should_behave_like 'RSS parser', '0.91'
  it_should_behave_like 'RSS parser', '1.0'
  it_should_behave_like 'RSS parser', '2.0'
  it_should_behave_like 'RSS parser', 'atom'

end

