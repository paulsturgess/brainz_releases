require 'spec_helper.rb'

describe BrainzReleases::Search do

  before { FakeWeb.allow_net_connect = false }
  after  { FakeWeb.allow_net_connect = true }

  describe "initialize" do

    context "when all attributes are set" do
      before do
        @brainz_search = BrainzReleases::Search.new do |search|
          search.user_agent = "Testing/0.1"
          search.start_date = Date.parse("1/1/2011")
          search.end_date = Date.parse("5/5/2011")
          search.name = "Bonobo"
          search.mbid = "123"
        end
      end
      
      it "should initialize the user agent" do
        @brainz_search.user_agent.should == "Testing/0.1"
      end

      it "should initialize the start date" do
        @brainz_search.start_date.should == Date.parse("1/1/2011")
      end

      it "should initialize the end date" do
        @brainz_search.end_date.should == Date.parse("5/5/2011")
      end

      it "should initialize the name" do
        @brainz_search.name.should == "Bonobo"
      end

      it "should initialize the mbid" do
        @brainz_search.mbid.should == "123"
      end
    end

    context "when the name and mbid are missing" do
      it "should raise an exception" do
        lambda {BrainzReleases::Search.new { |search| search.user_agent = "Foo"}}.should raise_exception(BrainzReleases::Search::ConfigError)
      end
    end
    
    context "when the user agent is missing" do
      it "should raise an exception" do
        lambda {BrainzReleases::Search.new { |search| search.mbid = "123"}}.should raise_exception(BrainzReleases::Search::ConfigError)
      end
    end

    context "when start date and end date are missing" do
      before do
        Date.stub(:now){Date.parse("1/1/2011")}
        @brainz_search = BrainzReleases::Search.new do |search|
          search.user_agent = "Testing/0.1"
          search.name = "Bonobo"
          search.mbid = "123"
        end
      end

      it "should initialize the start date" do
        @brainz_search.start_date.should_not be_nil
      end

      it "should initialize the end date" do
        @brainz_search.end_date.should_not be_nil
      end
    end

  end

  describe "uri" do

    context "when both the name and mbid are set" do
      before do
        @brainz_search = BrainzReleases::Search.new do |search|
          search.user_agent = "Testing/0.1"
          search.start_date = Date.parse("1/1/2011")
          search.end_date = Date.parse("5/5/2011")
          search.name = "Bonobo"
          search.mbid = "123"
        end
      end

      it "should use the mbid" do        
        @brainz_search.uri.should == URI.parse("http://musicbrainz.org/ws/2/release/?type=xml&query=arid%3A123+AND+date%3A%5B2011-01-01+TO+2011-05-05%5D")
      end

    end

  end

  # Note that you cannot compare two Nokogiri documents that have been parsed, even if you are parsing the same document
  # In any case we're not testing that Nokogiri works, we're testing that Nokogiri is called with the correct options
  describe "releases_xml" do

    before do
      @brainz_search = BrainzReleases::Search.new do |search|
        search.user_agent = "Testing/0.1"
        search.start_date = Date.parse("1/1/2011")
        search.end_date = Date.parse("5/5/2011")
        search.name = "Bonobo"
        search.mbid = "123"
      end
    end

    context "when the result is ok" do
      before do
        FakeWeb.register_uri(:get, "http://example.com", :body => File.read("spec/fixtures/ok.xml"))
        @brainz_search.stub(:uri){URI.parse("http://example.com")}
      end
      it "should call the artists url with Nokogiri parse to get the xml" do
        Nokogiri::XML::Document.should_receive(:parse).with(Net::HTTP.get(URI.parse("http://example.com")), nil, nil, 1)
        @brainz_search.releases_xml
      end
      it "should not raise the error message as an exception" do
        lambda {@brainz_search.releases_xml}.should_not raise_exception(BrainzReleases::Search::ResponseError)
      end
    end
    context "when the result is failed" do
      before do
        FakeWeb.register_uri(:get, "http://example.com", :body => "Some problem", :status => ["403", "Forbidden"])
        @brainz_search.stub(:uri){URI.parse("http://example.com")}
      end
      it "should raise the a ResponseError exception" do
        lambda {@brainz_search.releases_xml}.should raise_exception(BrainzReleases::Search::ResponseError)
      end
    end
  end

  describe "results" do

    before do
      @brainz_search = BrainzReleases::Search.new do |search|
        search.user_agent = "Testing/0.1"
        search.start_date = Date.parse("1/1/2011")
        search.end_date = Date.parse("5/5/2011")
        search.name = "Bonobo"
        search.mbid = "123"
      end
      @brainz_search.stub(:releases_xml).and_return(Nokogiri::XML(File.read("spec/fixtures/ok.xml")))
    end

    it "should include the releases returned by releases_xml" do
      @brainz_search.results.map(&:artist_name).should include("Bibio")
      @brainz_search.results.map(&:title).should include("Mind Bokeh")
      @brainz_search.results.first.should be_kind_of(BrainzReleases::Release)
      @brainz_search.results.length.should == 20
    end
  end

end