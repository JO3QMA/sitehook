# frozen_string_literal: true

require 'minitest/reporters'
Minitest::Reporters.use!
require 'minitest/autorun'

require_relative '../core/sitemap'

class SitemapTest < Minitest::Test
  describe 'Fetch Sitemap.xml' do
    def test_fetch_sitemap_response_code200
      assert_equal '200', Sitemap.fetch('https://diary.jo3qma.com/sitemap.xml').code
    end

    def test_fetch_sitemap_response_code404
      assert_equal '404', Sitemap.fetch('https://diary.jo3qma.com/sitemap_none.xml').code
    end
  end
end
