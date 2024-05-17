# frozen_string_literal: true

require 'net/https'
require 'uri'

# Sitemap Class
class Sitemap
  def self.fetch(uri)
    url = URI.parse(uri)
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true
    https.ca_file = '/usr/lib/ssl/cert.pem'
    https.verify_mode = OpenSSL::SSL::VERIFY_PEER
    https.verify_depth = 5
    response = ''
    https.start do
      response = https.get(url.path)
    end
    response
  end
end
