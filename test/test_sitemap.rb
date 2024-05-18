# frozen_string_literal: true

require 'minitest/reporters'
Minitest::Reporters.use!
require 'minitest/autorun'
require 'webmock/minitest'

require_relative '../core/sitemap'

class SitemapTest < Minitest::Test
  describe 'Fetch Sitemap.xml' do
    def setup
      stub_request(:get, 'https://www.example.com/sitemap.xml')
        .to_return(status: 200, body: '', headers: {})
      stub_request(:get, 'https://404.example.com/sitemap.xml')
        .to_return(status: 404, body: '', headers: {})
    end

    def test_fetch_sitemap_response_code200
      assert_equal '200', Sitemap.fetch('https://www.example.com/sitemap.xml').code
    end

    def test_fetch_sitemap_response_code404
      assert_equal '404', Sitemap.fetch('https://404.example.com/sitemap.xml').code
    end
  end
end
