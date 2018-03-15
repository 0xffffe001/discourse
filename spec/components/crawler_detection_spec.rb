require 'rails_helper'
require_dependency 'crawler_detection'

describe CrawlerDetection do
  describe "crawler?" do

    it "can be amended via site settings" do
      SiteSetting.crawler_user_agents = 'Mooble|Kaboodle+*'
      expect(CrawlerDetection.crawler?("Mozilla/5.0 Safari (compatible; Kaboodle+*/2.1; +http://www.google.com/bot.html)")).to eq(true)
      expect(CrawlerDetection.crawler?("Mozilla/5.0 Safari (compatible; Mooble+*/2.1; +http://www.google.com/bot.html)")).to eq(true)
      expect(CrawlerDetection.crawler?("Mozilla/5.0 Safari (compatible; Gooble+*/2.1; +http://www.google.com/bot.html)")).to eq(false)
    end

    it "returns true for crawler user agents" do
      # https://support.google.com/webmasters/answer/1061943?hl=en
      expect(described_class.crawler?("Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)")).to eq(true)
      expect(described_class.crawler?("Googlebot/2.1 (+http://www.google.com/bot.html)")).to eq(true)
      expect(described_class.crawler?("Googlebot-News")).to eq(true)
      expect(described_class.crawler?("Googlebot-Image/1.0")).to eq(true)
      expect(described_class.crawler?("Googlebot-Video/1.0")).to eq(true)
      expect(described_class.crawler?("(compatible; Googlebot-Mobile/2.1; +http://www.google.com/bot.html)")).to eq(true)
      expect(described_class.crawler?("Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)")).to eq(true)
      expect(described_class.crawler?("(compatible; Mediapartners-Google/2.1; +http://www.google.com/bot.html)")).to eq(true)
      expect(described_class.crawler?("Mediapartners-Google")).to eq(true)
      expect(described_class.crawler?("AdsBot-Google (+http://www.google.com/adsbot.html)")).to eq(true)
      expect(described_class.crawler?("Twitterbot")).to eq(true)
      expect(described_class.crawler?("facebookexternalhit/1.1 (+http(s)://www.facebook.com/externalhit_uatext.php)")).to eq(true)
      expect(described_class.crawler?("Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)")).to eq(true)
      expect(described_class.crawler?("Baiduspider+(+http://www.baidu.com/search/spider.htm)")).to eq(true)
      expect(described_class.crawler?("Mozilla/5.0 (compatible; YandexBot/3.0; +http://yandex.com/bots)")).to eq(true)
    end

    it "returns false for non-crawler user agents" do
      expect(described_class.crawler?("Mozilla/5.0 (Windows NT 6.2; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1667.0 Safari/537.36")).to eq(false)
      expect(described_class.crawler?("Mozilla/5.0 (Windows NT 6.3; Trident/7.0; rv:11.0) like Gecko")).to eq(false)
      expect(described_class.crawler?("Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.2; Trident/6.0)")).to eq(false)
      expect(described_class.crawler?("Mozilla/5.0 (iPad; CPU OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5355d Safari/8536.25")).to eq(false)
      expect(described_class.crawler?("Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:25.0) Gecko/20100101 Firefox/25.0")).to eq(false)
      expect(described_class.crawler?("Mozilla/5.0 (Linux; U; Android 4.0.3; ko-kr; LG-L160L Build/IML74K) AppleWebkit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30")).to eq(false)

      expect(described_class.crawler?("DiscourseAPI Ruby Gem 0.19.0")).to eq(true)
      expect(described_class.crawler?("Pingdom.com_bot_version_1.4_(http://www.pingdom.com/)")).to eq(true)
      expect(described_class.crawler?("LogicMonitor SiteMonitor/1.0")).to eq(true)
      expect(described_class.crawler?("Java/1.8.0_151")).to eq(true)
      expect(described_class.crawler?("Mozilla/5.0 (compatible; Yahoo! Slurp; http://help.yahoo.com/help/us/ysearch/slurp)")).to eq(true)
    end

  end

  describe 'allow_crawler?' do
    it 'returns true if whitelist and blacklist are blank' do
      expect(CrawlerDetection.allow_crawler?('Googlebot/2.1 (+http://www.google.com/bot.html)')).to eq(true)
    end

    context 'whitelist is set' do
      before do
        SiteSetting.whitelisted_crawler_user_agents = 'Googlebot|Twitterbot'
      end

      it 'returns true for matching user agents' do
        expect(CrawlerDetection.allow_crawler?('Googlebot/2.1 (+http://www.google.com/bot.html)')).to eq(true)
        expect(CrawlerDetection.allow_crawler?('Googlebot-Image/1.0')).to eq(true)
        expect(CrawlerDetection.allow_crawler?('Twitterbot')).to eq(true)
      end

      it 'returns false for user agents that do not match' do
        expect(CrawlerDetection.allow_crawler?('facebookexternalhit/1.1 (+http(s)://www.facebook.com/externalhit_uatext.php)')).to eq(false)
        expect(CrawlerDetection.allow_crawler?('Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)')).to eq(false)
        expect(CrawlerDetection.allow_crawler?('')).to eq(false)
      end

      context 'and blacklist is set' do
        before do
          SiteSetting.blacklisted_crawler_user_agents = 'Googlebot-Image'
        end

        it 'ignores the blacklist' do
          expect(CrawlerDetection.allow_crawler?('Googlebot-Image/1.0')).to eq(true)
        end
      end
    end

    context 'blacklist is set' do
      before do
        SiteSetting.blacklisted_crawler_user_agents = 'Googlebot|Twitterbot'
      end

      it 'returns true for crawlers that do not match' do
        expect(CrawlerDetection.allow_crawler?('Mediapartners-Google')).to eq(true)
        expect(CrawlerDetection.allow_crawler?('facebookexternalhit/1.1 (+http(s)://www.facebook.com/externalhit_uatext.php)')).to eq(true)
        expect(CrawlerDetection.allow_crawler?('')).to eq(true)
      end

      it 'returns false for user agents that match' do
        expect(CrawlerDetection.allow_crawler?('Googlebot/2.1 (+http://www.google.com/bot.html)')).to eq(false)
        expect(CrawlerDetection.allow_crawler?('Googlebot-Image/1.0')).to eq(false)
        expect(CrawlerDetection.allow_crawler?('Twitterbot')).to eq(false)
      end
    end
  end

  describe 'is_blocked_crawler?' do
    it 'is false if user agent is a crawler and no whitelist or blacklist is defined' do
      expect(CrawlerDetection.is_blocked_crawler?('Twitterbot')).to eq(false)
    end

    it 'is false if user agent is not a crawler and no whitelist or blacklist is defined' do
      expect(CrawlerDetection.is_blocked_crawler?('Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36')).to eq(false)
    end

    it 'is true if user agent is a crawler and is not whitelisted' do
      SiteSetting.whitelisted_crawler_user_agents = 'Googlebot'
      expect(CrawlerDetection.is_blocked_crawler?('Twitterbot')).to eq(true)
    end

    it 'is false if user agent is not a crawler and there is a whitelist' do
      SiteSetting.whitelisted_crawler_user_agents = 'Googlebot'
      expect(CrawlerDetection.is_blocked_crawler?('Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36')).to eq(false)
    end

    it 'is true if user agent is a crawler and is blacklisted' do
      SiteSetting.blacklisted_crawler_user_agents = 'Twitterbot'
      expect(CrawlerDetection.is_blocked_crawler?('Twitterbot')).to eq(true)
    end

    it 'is true if user agent is a crawler and is not blacklisted' do
      SiteSetting.blacklisted_crawler_user_agents = 'Twitterbot'
      expect(CrawlerDetection.is_blocked_crawler?('Googlebot')).to eq(false)
    end

    it 'is false if user agent is not a crawler and blacklist is defined' do
      SiteSetting.blacklisted_crawler_user_agents = 'Mozilla'
      expect(CrawlerDetection.is_blocked_crawler?('Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36')).to eq(false)
    end

  end
end
