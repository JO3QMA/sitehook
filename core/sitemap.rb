# frozen_string_literal: true

require 'net/https'
require 'uri'
require 'nokogiri'
require 'time'
require 'logger'

# Sitemap Class
class Sitemap
  attr_reader :urls, :response

  def initialize(source)
    @logger = Logger.new($stdout)
    if source =~ URI::DEFAULT_PARSER.make_regexp
      fetch_sitemap_from_url(source)
    else
      fetch_sitemap_from_file(source)
    end
    parse_sitemap
  rescue StandardError => e
    handle_error('Error initializing Sitemap', e)
  end

  private

  def fetch_sitemap_from_url(url, limit: 10)
    raise ArgumentError, 'HTTP redirect too deep' if limit.zero?

    uri = URI.parse(url)
    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https', verify_mode: OpenSSL::SSL::VERIFY_PEER) do |http|
      @response = http.get(uri.path)
    end

    case @response
    when Net::HTTPSuccess
      @sitemap_xml = @response.body
    when Net::HTTPRedirection
      fetch_sitemap_from_url(@response['location'], limit: limit - 1)
    else
      raise "Failed to fetch sitemap: #{@response.code} #{@response.message}"
    end
  rescue StandardError => e
    handle_error('Error fetching sitemap from URL', e)
  end

  def fetch_sitemap_from_file(path)
    @sitemap_xml = File.read(path)
  rescue StandardError => e
    handle_error('Error reading sitemap file', e)
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
  rescue StandardError => e
    handle_error('Error parsing sitemap', e)
  end

  def handle_error(message, exception)
    @logger.error("#{message}: #{exception.message}")
    @logger.debug(exception.backtrace.join("\n"))
    @urls = []
  end
end
