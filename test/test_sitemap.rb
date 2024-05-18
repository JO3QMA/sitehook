# frozen_string_literal: true

require 'minitest/reporters'
Minitest::Reporters.use!
require 'minitest/autorun'
require 'webmock/minitest'

require_relative '../core/sitemap'

class SitemapTest < Minitest::Test
  describe 'Fetch sitemap.xml' do
    def setup
      @valid_url = 'https://www.example.com/sitemap.xml'
      @invalid_url = 'https://404.example.com/sitemap.xml'
      stub_request(:get, @valid_url)
        .to_return(status: 200, body: '', headers: {})
      stub_request(:get, @invalid_url)
        .to_return(status: 404, body: '', headers: {})
      @sitemap = Sitemap.new
    end

    def test_fetch_sitemap_response_code200
      assert_equal '200', @sitemap.fetch(@valid_url).code
    end

    def test_fetch_sitemap_response_code404
      assert_equal '404', @sitemap.fetch(@invalid_url).code
    end
  end
end
