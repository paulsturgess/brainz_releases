require 'spec_helper.rb'

describe BrainzReleases::Release do

  describe "build_from_node" do

    before do
      node = Nokogiri::XML(File.read("spec/fixtures/ok.xml")).xpath('//xmlns:release').first
      @release = BrainzReleases::Release.build_from_node(node)
    end

    it "should set the attributes" do
      @release.mbid.should == "4a46ee61-75b5-4e2b-ac2e-81ef2ccec0f9"
      @release.artist_name.should == "Bibio"
      @release.artist_mbid.should == "9f9953f0-68bb-4ce3-aace-2f44c87f0aa3"
      @release.title.should == "Fi"
      @release.release_type.should == "Album"
      @release.date_available.should == "2005-02-08"
      @release.track_count.should == "17"
      @release.format.should == "CD"
      @release.label.should == "Mush Records"
      @release.country.should == "US"
    end

    it "should be able to list the attributes as a hash" do
      @release.attributes.should == {
        :mbid => "4a46ee61-75b5-4e2b-ac2e-81ef2ccec0f9",
        :artist_name => "Bibio",
        :artist_mbid => "9f9953f0-68bb-4ce3-aace-2f44c87f0aa3",
        :title => "Fi",
        :release_type => "Album",
        :date_available => "2005-02-08",
        :track_count => "17",
        :format => "CD",
        :label => "Mush Records",
        :country => "US"
      }
    end

  end

end