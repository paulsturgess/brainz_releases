module BrainzReleases
  class Release

    attr_accessor :mbid, :title, :release_type, :date_available, :artist_name, :artist_mbid, :label, :track_count, :country, :format

    def initialize(*args, &block)
      self.instance_eval(&block) if block
    end

    def self.build_from_node(node)
      Release.new do |release|
        release.mbid = node["id"]
        release.artist_name = node.xpath("//xmlns:release[@id='#{release.mbid}']/xmlns:artist-credit/xmlns:name-credit/xmlns:artist/xmlns:name").first.content rescue nil
        release.artist_mbid = node.xpath("//xmlns:release[@id='#{release.mbid}']/xmlns:artist-credit/xmlns:name-credit/xmlns:artist").first['id']
        release.title = node.xpath("//xmlns:release[@id='#{release.mbid}']/xmlns:title").first.content rescue nil
        release.release_type = node.xpath("//xmlns:release[@id='#{release.mbid}']/xmlns:release-group").first['type']
        release.date_available = node.xpath("//xmlns:release[@id='#{release.mbid}']/xmlns:date").first.content rescue nil
        release.track_count = node.xpath("//xmlns:release[@id='#{release.mbid}']/xmlns:medium-list/xmlns:track-count").first.content rescue nil
        release.format = node.xpath("//xmlns:release[@id='#{release.mbid}']/xmlns:medium-list/xmlns:medium/xmlns:format").first.content rescue nil
        release.label = node.xpath("//xmlns:release[@id='#{release.mbid}']/xmlns:label-info-list/xmlns:label-info/xmlns:label/xmlns:name").first.content rescue nil
        release.country = node.xpath("//xmlns:release[@id='#{release.mbid}']/xmlns:country").first.content rescue nil
      end
    end

    # Returns a hash of all the attributes with their names as keys and the values of the attributes as values.
    def attributes
      Hash[instance_variables.map { |name| [name[1..-1].to_sym, instance_variable_get(name)] }]
    end

  end
end