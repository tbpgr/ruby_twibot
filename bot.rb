# coding:utf-8
 
require 'dotenv'
require 'twitter'
require 'tweetstream'
require 'eto'
require 'date'
require 'ruboty-sonar'

class RobertGarcia
  attr_accessor :client, :stream_client

  def initialize
    Dotenv.load
    @client = new_tweet_client_instance
    @stream_client = new_teetstreem_client_instance
  end

  def tweet(text)
    @client.update(text)
  end

  def reply(text, target_id, tweet_id)
    rep_text = "@#{target_id} #{text}"
    @client.update("@#{target_id} #{text}" ,{ in_reply_to_status_id: tweet_id } )
  end

  def favorite(tweet_id)
    @client.favorite(tweet_id)
  end
 
  def retweet(tweet_id)
    @client.retweet(tweet_id)
  end

  private

  def new_tweet_client_instance
    Twitter::REST::Client.new { |config|auth(config) }
  end

  def new_teetstreem_client_instance
    TweetStream.configure do |config|
      config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
      config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"]
      config.oauth_token         = ENV["TWITTER_ACCESS_TOKEN"]
      config.oauth_token_secret  = ENV["TWITTER_ACCESS_TOKEN_SECRET"]
      config.auth_method         = :oauth
    end
    TweetStream::Client.new
  end

  def auth(config)
    config.consumer_key         = ENV["TWITTER_CONSUMER_KEY"]
    config.consumer_secret      = ENV["TWITTER_CONSUMER_SECRET"]
    config.access_token         = ENV["TWITTER_ACCESS_TOKEN"]
    config.access_token_secret  = ENV["TWITTER_ACCESS_TOKEN_SECRET"]
    config
  end
end

def current_time
  DateTime.now.strftime('%Y/%m/%d %H:%M:%S')
end

# Ruboty の ダウンロードランキングをツイート
# 1-9位まで対応
def ruboty_gem_rank(pos)
  ruboty_info = RubotySonar.ranking(10)[pos - 1]
  <<-EOS
Ruboty Download Ranking
No#{pos} #{ruboty_info[:name]}(DL #{ruboty_info[:downloads]}) by #{ruboty_info[:authors]}
at #{current_time}
  EOS
end

# Ruboty の Plugin をランダムで紹介
def ruboty_gem_random
  ruboty_info = RubotySonar.random
  text =<<-EOS
RubotyPluginランダム紹介
#{ruboty_info[:name]}
#{ruboty_info[:desc]}
#{ruboty_info[:homepage_uri]}
at #{current_time}
  EOS
  text.slice(0, 140)
end

# Not YAGNI。そのうち使う
def author_only(robert_garcia, twitter_id, tweet)
  return unless twitter_id == 'tbpgr'
  # TODO: 管理者限定機能を作ったら利用
end

def anyone(robert_garcia, twitter_id, tweet)
  return if twitter_id.nil?
  tweet = tweet.gsub("@tbpgr_bot", '')
  case tweet
  when /^\s*十二支 (.*)(\s*)(?<year>\d{4})\z/
    year = Regexp.last_match[:year]
    eto = Eto.name(year.to_i)
    robert_garcia.tweet "西暦#{year}年 の十二支は #{eto} 年 #{current_time}"
  when /^\s*十干十二支 (.*)(\s*)(?<year>\d{4})\z/
    year = Regexp.last_match[:year]
    eto = Eto.name(year.to_i, false )
    robert_garcia.tweet "西暦#{year}年 の十干十二支は #{eto} 年 #{current_time}"
  when /^\s*ruboty (.*)(\s*)ランキング (?<pos>[\d]{1})\z/
    robert_garcia.tweet(ruboty_gem_rank(Regexp.last_match[:pos].to_i))
  when /^\s*ruboty (.*)(\s*)ランダム\z/
    robert_garcia.tweet(ruboty_gem_random)
  end
end

robert_garcia = RobertGarcia.new
robert_garcia.stream_client.on_timeline_status do |status|
  begin
    twitter_id = status.user.screen_name
    tweet = status.text
    # TODO: そのうち使う管理者限定モード
    # author_only(twitter_id, tweet)
    anyone(robert_garcia, twitter_id, tweet)
  rescue => e
    robert_garcia.tweet "bad request #{current_time}"
  end
end

robert_garcia.stream_client.userstream  do |tweet|
end
