# -*- encoding: utf-8 -*-

require 'spec_helper'

describe 'User#reload_sites', :clear=>true do
  context "RSS 1.0" do
    let!(:target){ Fabricate :user, :sites=>[Fabricate(:site, :failed_at=>1.day.ago)] }
    let!(:failed_at_was){ target.sites.last.failed_at }
    let!(:stub_site){ Fabricate(:example_user).sites.last }
    let!(:stub_entry){ stub_site.entries.first }

    before :all do
      any_instance_of Site do |site|
        stub(site).feed{ Feedzirra::Feed.parse stub_site.to_feed('1.0').to_s }
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

  context "RSS 2.0" do
    let!(:target){ Fabricate :user, :sites=>[Fabricate(:site, :failed_at=>1.day.ago)] }
    let!(:failed_at_was){ target.sites.last.failed_at }
    let!(:stub_site){ Fabricate(:example_user).sites.last }
    let!(:stub_entry){ stub_site.entries.first }

    before :all do
      any_instance_of Site do |site|
        stub(site).feed{ Feedzirra::Feed.parse stub_site.to_feed('2.0').to_s }
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

  context "Atom" do
    let!(:target){ Fabricate :user, :sites=>[Fabricate(:site, :failed_at=>1.day.ago)] }
    let!(:failed_at_was){ target.sites.last.failed_at }
    let!(:stub_site){ Fabricate(:example_user).sites.last }
    let!(:stub_entry){ stub_site.entries.first }

    before :all do
      any_instance_of Site do |site|
        stub(site).feed{ Feedzirra::Feed.parse stub_site.to_feed('2.0').to_s }
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

  context "フィードの取得に失敗したサイト" do
    let!(:target){ Fabricate :user, :sites=>[Fabricate(:site, :entries=>[Fabricate.build(:entry)])] }
    let!(:attr_was){ target.sites.last.attributes }
    let!(:entry_was){ target.sites.last.entries.last }

    before :all do
      any_instance_of(Site){|site| stub(site).feed{ raise } }
      target.reload_sites rescue nil
    end

    it "サイト情報は更新されない" do
      target.sites.last.title.should    eql attr_was[:title]
      target.sites.last.site_uri.should eql attr_was[:site_uri]
    end

    it "エントリ一覧は更新されない" do
      target.sites.last.entries.each do |entry|
        entry.title.should      eql entry_was.title
        entry.content.should    eql entry_was.content
        entry.categories.should eql entry_was.categories
        entry.link.should       eql entry_was.link
        entry.date.should       eql entry_was.date
      end
    end

    it "フィードの取得に失敗した日時が登録されていること" do
      target.sites.last.failed_at.should_not be_nil
    end
  end
end

