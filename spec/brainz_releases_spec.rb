require 'spec_helper.rb'

describe BrainzReleases do

  describe "::search" do    
    it "should call search" do
      BrainzReleases::Search.should_receive(:search)
      BrainzReleases.search do |search| 
        search.mbid = "123"
      end
    end
  end

end