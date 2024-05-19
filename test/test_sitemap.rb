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
      require 'time'
      stub_request(:get, 'https://www.example.com/sitemap.xml')
        .to_return(
          status: 200,
          body: File.new('./test/sitemap.xml'),
          headers: {}
        )
      @sitemap = Sitemap.new('https://www.example.com/sitemap.xml')
    end

    describe 'sitemap urls size test' do
      def test_parse_sitemap_urls_size
        assert_equal 5, @sitemap.urls.size
      end
    end

    describe 'sitemap loc test' do
      def test_parse_sitemap_1st_loc
        assert_equal 'https://www.example.com/', @sitemap.urls.first[:loc]
      end

      def test_parse_sitemap_2nd_loc
        assert_equal 'https://www.example.com/url01', @sitemap.urls[1][:loc]
      end

      def test_parse_sitemap_3rd_loc
        assert_equal 'https://www.example.com/directory/url02', @sitemap.urls[2][:loc]
      end
    end

    describe 'sitemap lastmod test' do
      def test_parse_sitemap_1st_lastmod
        assert_nil @sitemap.urls.first[:lastmod]
      end

      def test_parse_sitemap_2nd_lastmod
        assert_equal Time.parse('2024-02-01T00:00:00+09:00'), @sitemap.urls[1][:lastmod]
      end

      def test_parse_sitemap_3rd_lastmod
        assert_equal Time.parse('2024-03-21T00:00:00+09:00'), @sitemap.urls[2][:lastmod]
      end

      def test_parse_sitemap_4th_lastmod
        assert_equal Time.parse('2024-03-21T01:23:45Z'), @sitemap.urls[3][:lastmod]
      end

      def test_parse_sitemap_5th_lastmod
        assert_equal Time.parse('2024-03-22'), @sitemap.urls[4][:lastmod]
      end
    end
  end
end
