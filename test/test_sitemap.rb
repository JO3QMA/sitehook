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
    end

    def test_fetch_sitemap_response_code200
      sitemap = Sitemap.new(@valid_url)
      assert_equal '200', sitemap.response.code
    end

    def test_fetch_sitemap_response_code404
      sitemap = Sitemap.new(@invalid_url)
      assert_equal '404', sitemap.response.code
    end
  end

  describe 'Parse sitemap.xml' do
    def setup
      stub_request(:get, 'https://www.example.com/sitemap.xml')
        .to_return(
          status: 200,
          body: File.new('./test/sitemap.xml'),
          headers: {}
        )
      @sitemap = Sitemap.new('https://www.example.com/sitemap.xml')
      @sitemap.parse
    end

    def test_parse_sitemap_first_loc
      assert_equal 'https://www.example.com/', @sitemap.urls.first[:loc]
    end
  end
end
