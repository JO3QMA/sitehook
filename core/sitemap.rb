# frozen_string_literal: true

require 'net/https'
require 'uri'
require 'nokogiri'
require 'time'

# Sitemap Class
class Sitemap
  attr_reader :response

  def initialize(uri)
    @response = fetch(uri)
    @namespace = {
      "ns": 'http://www.sitemaps.org/schemas/sitemap/0.9'
    }
    @body = Nokogiri::XML(@response.body)
  end

  def fetch(uri)
    url = URI.parse(uri)
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true
    https.verify_mode = OpenSSL::SSL::VERIFY_PEER
    https.start do
      https.get(url.path)
    end
  end

  def urls
    @body.xpath('//ns:url', @namespace).map do |node|
      url = {}
      node.children.each do |child_node|
        next if child_node.node_type == 3 # タグ間の空白文字以外の文字
        next if child_node.node_type == 8 # コメント
        next if child_node.node_type == 14 # タグ間の空白文字

        url[child_node.name.to_sym] = if child_node.name == 'lastmod'
                                        Time.parse(child_node.text)
                                      else
                                        child_node.text
                                      end
      end
      url
    end
  end
end
