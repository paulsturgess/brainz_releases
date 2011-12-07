require 'nokogiri'
require 'open-uri'
require 'net/http'
require 'CGI'
require 'Date' unless defined?(Date) == "constant"

module BrainzReleases
  class Search

    class Error < StandardError; end
    class ResponseError < Error; end
    class ConfigError < Error; end
    
    attr_accessor :name, :mbid, :start_date, :end_date, :user_agent
    
    def self.search(*args, &block)
      Search.new(*args, &block).results
    end
    
    def initialize(*args, &block)
      (block.arity < 1 ? self.instance_eval(&block) : block.call(self)) if block
      raise ConfigError, "You must provide a :name or :mbid parameter" if [name, mbid].all?(&:nil?)
      raise ConfigError, "You must provide a user_agent parameter to identify your requests" if user_agent.nil?
    end
    
    def start_date
      @start_date ||= Date.today << 1
    end
    
    def end_date
      @end_date ||= Date.today >> 1
    end

    #http://musicbrainz.org/ws/2/release/?type=xml&query=arid:2ff0dfc6-0542-4bbc-a44a-60605c074ba6

    # Musicbrainz uri to request releases
    def uri
      URI.parse("http://musicbrainz.org/ws/2/release/?type=xml&query=#{query}")
    end

    def releases_xml
      http = Net::HTTP.new(uri.host)
      request = Net::HTTP::Get.new(uri.request_uri, {"User-Agent" => user_agent})
      response = http.request(request)
      case response.code
      when "200"
        @releases_xml = Nokogiri::XML(response.body)
      else
        raise ResponseError, "There is a problem accessing the Music Brainz api"
      end
    end

    # Returns an array of BrainzReleases::Release objects
    def results
      (releases = []).tap do 
        releases_xml.xpath('//xmlns:release').each do |node|
          releases << BrainzReleases::Release.build_from_node(node)
        end
      end
    end
    
    private 
    
    def query
      CGI.escape("#{artist_param} AND date:[#{start_date.to_s} TO #{end_date.to_s}]")
    end

    def artist_param
      mbid && mbid != "" ? "arid:#{mbid}" : "artist:#{name}"
    end

  end
end