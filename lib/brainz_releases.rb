module BrainzReleases
    
  def self.search(&block)
    BrainzReleases::Search.search &block
  end
  
end

require 'brainz_releases/search'
require 'brainz_releases/release'