# coding:utf-8
 
require 'dotenv'
require 'twitter'
require 'tweetstream'
require 'eto'
require 'date'
require 'ruboty-sonar'

class RobertGarcia
  VERSION = '1.0.0'
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
  text =<<-EOS
Ruboty Download Ranking
No#{pos} #{ruboty_info[:name]}(DL #{ruboty_info[:downloads]}) by #{ruboty_info[:authors]}
at #{current_time} #ruboty
  EOS
  text.slice(0, 140)
end

# Ruboty の Plugin をランダムで紹介
def ruboty_gem_random
  ruboty_info = RubotySonar.random
  text =<<-EOS
RubotyPluginランダム紹介
#{ruboty_info[:name]}
#{ruboty_info[:homepage_uri]}
at #{current_time} #ruboty
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
    robert_garcia.tweet "西暦#{year}年 の十二支は #{eto} 年 \n#{current_time}"
  when /^\s*十干十二支 (.*)(\s*)(?<year>\d{4})\z/
    year = Regexp.last_match[:year]
    eto = Eto.name(year.to_i, false )
    robert_garcia.tweet "西暦#{year}年 の十干十二支は #{eto} 年 \n#{current_time}"
  when /^\s*ruboty (.*)(\s*)ランキング (?<pos>[\d]{1})\z/
    robert_garcia.tweet(ruboty_gem_rank(Regexp.last_match[:pos].to_i))
  when /^\s*ruboty (.*)(\s*)ランダム\z/
    robert_garcia.tweet(ruboty_gem_random)
  when /^(.*)(\s*)今のバージョンは？\z/
    robert_garcia.tweet("@#{twitter_id} #{RobertGarcia::VERSION}です \n#{current_time}")
  when /^(.*)(\s*)ヘルプどこ？\z/
    robert_garcia.tweet("@#{twitter_id} どうぞ(´・ω・)つ https://github.com/tbpgr/ruby_twibot/blob/master/README.md \n#{current_time}")
  end
end

module RandomTweet
  ADV_MESSAGES = [
    "Tbpgr Slides |> 多言語ゴルフ場デスマコロシアム。デスマコロシアムとは？ |> http://tbpgr.github.io/deathma_slide/ #codeiq #デスマコロシアム",
    "Tbpgr Qiita |> GitHub Flow 図解 |> http://qiita.com/tbpgr/items/4ff76ef35c4ff0ec8314",
    "Tbpgr Qiita |> Ruby | アノテーションコメント（TODO、FIXME、OPTIMIZE、HACK、REVIEW） |> http://qiita.com/tbpgr/items/1c046a877c6be4d89876 #ruby",
    "Tbpgr Qiita |> Ruby | Ruby の private と protected 。歴史と使い分け |> http://qiita.com/tbpgr/items/6f1c0c7b77218f74c63e #ruby",
    "Tbpgr Qiita |> 条件分岐とループベースのロジックからコレクションパイプラインを利用したロジックへ |> http://qiita.com/tbpgr/items/190859b5080914896db8 #ruby",
    "Tbpgr Qiita |> Ruby | RubyKaigi2014で話題に。安全に Ruby のコードを変換できる Synvert gem をインストール |> http://qiita.com/tbpgr/items/8bdb92fa8f9324727336 #ruby",
    "Tbpgr Qiita |> Itamae 関連記事 |> https://qiita.com/tbpgr/items/8b0170341b8095ced543 #itamae",
    "Tbpgr Qiita |> Gemfury 関連記事 |> https://qiita.com/tbpgr/items/a534dd2aa10995abc37a #gemfury",
    "Tbpgr Qiita |> Docker 関連記事 |> https://qiita.com/tbpgr/items/f49ea1df791612aca94f #docker",
    "Tbpgr Qiita |> Elixir 関連記事 |> https://qiita.com/tbpgr/items/a55ef9ea40200c5fd8ec #docker",
    "Tbpgr Qiita |> Reveal.js 関連記事 |> https://qiita.com/tbpgr/items/dfe984e65323371fb9f0 #revealjs",
    "Tbpgr Qiita |> Graphviz 関連記事 |> https://qiita.com/tbpgr/items/76d0379bb83ec64fbdb3 #graphviz",
    "Tbpgr Qiita |> Wercker 関連記事 |> https://qiita.com/tbpgr/items/57ea0d1e1b15700a6ff3 #wercker",
    "Tbpgr Qiita |> Kandan 関連記事 |> https://qiita.com/tbpgr/items/94609b53d083895b0d90 #kandan",
    "Tbpgr Qiita |> Hubot 関連記事 |> https://qiita.com/tbpgr/items/544d397e2b6c17b24292 #hubot",
    "Tbpgr Qiita |> Vagrant 関連記事 |> https://qiita.com/tbpgr/items/e97057f4bd01c23504b6 #vagrant",
    "Tbpgr Qiita |> Ruboty 関連記事 |> https://qiita.com/tbpgr/items/f16c506c4a2636e95d34 #ruboty",
    "Tbpgr Qiita |> GitLab CI 関連記事 |> https://qiita.com/tbpgr/items/e079210ac52822a33559 #gitlab",
    "Tbpgr Qiita |> GitLab API 関連記事 |> https://qiita.com/tbpgr/items/4f301f8e7788cfbd5ace #gitlab",
    "Tbpgr Qiita |> RuboCop API 関連記事 |> https://qiita.com/tbpgr/items/edbfecb6a6789dd54f47 #rubocop",
    "Ruboty のコードリーディングで Ruboty の仕組みを理解すると共に Ruby の設計・実装の定石を学ぶ |> http://qiita.com/tbpgr/items/5887003cd2e69e9d8867 #rubocop",
    "Tbpgr Gems |> ruboty plugin の README を生成する ruboty-megen gem |> https://github.com/tbpgr/ruboty-megen #ruboty",
    "Tbpgr Gems |> ruboty plugin の Qiita 記事を生成する ruboty-articlegen gem |> https://github.com/tbpgr/ruboty-articlegen #ruboty",
    "Tbpgr Gems |> 西暦から和暦を取得する ruboty plugin,  ruboty-wareki gem |> https://github.com/tbpgr/ruboty-wareki #ruboty",
    "Tbpgr Gems |> 西暦から十二支の名称、emoji を取得する ruboty plugin,  ruboty-eto gem |> https://github.com/tbpgr/ruboty-eto #ruboty",
    "Tbpgr Gems |> 西暦から十二支の名称、emoji を取得する eto gem |> https://github.com/tbpgr/eto #ruboty",
    "Tbpgr Gems |> 日付フォーマットのディレクトリ一括作成を行う defoker gem |> https://github.com/tbpgr/defoker #ruboty",
    "Tbpgr Slides |> 日付フォーマットのディレクトリ一括作成を行う defoker gem スライドショー |> http://tbpgr.github.io/defoker_slide/ #defoker",
  ]

  IDLE_TALKS = [
    '呼んだ？',
    '中の人などいない',
    'インド人を右に',
    'ザンギュラのスーパーウリアッ上',
    'ジャンプ大パチン',
  ]

  MESSAGES = ADV_MESSAGES + IDLE_TALKS
end

def random_advertise(robert_garcia)
  return if rand > 0.1
  robert_garcia.tweet("#{RandomTweet::MESSAGES.sample} \n#{current_time}")
end

robert_garcia = RobertGarcia.new
robert_garcia.stream_client.on_timeline_status do |status|
  begin
    random_advertise(robert_garcia)
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
