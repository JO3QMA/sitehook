# frozen_string_literal: true

require 'net/https'
require 'uri'
require 'nokogiri'
require 'time'

# Sitemap Class
class Sitemap
  attr_reader :urls, :response

  def initialize(source)
    if source =~ URI::DEFAULT_PARSER.make_regexp
      fetch_sitemap_from_url(source)
    else
      fetch_sitemap_from_file(source)
    end
    parse_sitemap
  end

  private

  def fetch_sitemap_from_url(url)
    uri = URI.parse(url)
    request = Net::HTTP.new(uri.host, uri.port)
    if uri.scheme == 'https'
      request.use_ssl = true
      request.verify_mode = OpenSSL::SSL::VERIFY_PEER
    end
    @response = request.start do
      request.get(uri.path)
    end
    @sitemap_xml = @response.body
  end

  def fetch_sitemap_from_file(path)
    @sitemap_xml = File.read(path)
  end

  def parse_sitemap
    doc = Nokogiri::XML(@sitemap_xml)
    namespace = { "ns": 'http://www.sitemaps.org/schemas/sitemap/0.9' }
    @urls = doc.xpath('//ns:url', namespace).map do |node|
      url = {}
      node.children.each do |child_node|
        case child_node.name
        when 'loc'
          url[:loc] = URI.parse(child_node.text)
        when 'lastmod'
          url[:lastmod] = Time.parse(child_node.text)
        end
      end
      url
    end
  end
end
