# frozen_string_literal: true

require 'net/https'
require 'uri'

# Sitemap Class
class Sitemap
  def self.fetch(uri)
    url = URI.parse(uri)
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true
    https.verify_mode = OpenSSL::SSL::VERIFY_PEER
    https.start do
      https.get(url.path)
    end
  end
end
