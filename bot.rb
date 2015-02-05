# coding:utf-8
 
require 'dotenv'
require 'twitter'
require 'tweetstream'
require 'eto'
require 'date'
require 'ruboty-sonar'
require 'qiita_scouter_core'

class RobertGarcia
  VERSION = '1.0.3'
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


# @tenyawanya_bot に話しかける
def talk_to_tenyawanya_bot
  tanya_keys = %w(とり こんばんは（こんばんわ） かわいい よくできました ちいさい すもけ おはよう おやすみ いえーい ななちん らーめん ミラノ風 たべもの おやつ)
  "@tenyawanya_bot #{tanya_keys.sample}"
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
    robert_garcia.tweet("@#{twitter_id} #{RobertGarcia::VERSION}です。詳細はこちらを どうぞ(´・ω・)つ https://github.com/tbpgr/ruby_twibot/blob/master/CHANGELOG.md \n#{current_time}")
  when /^(.*)(\s*)ヘルプどこ？\z/
    robert_garcia.tweet("@#{twitter_id} どうぞ(´・ω・)つ https://github.com/tbpgr/ruby_twibot/blob/master/README.md \n#{current_time}")
  when /^(.*)(\s*)てんやわんやボットを呼んで\z/
    robert_garcia.tweet("#{talk_to_tenyawanya_bot} \n#{current_time}")
  when /^\s(?<user>.*)のQiita戦闘力はいくつ？\s*(.*)\z/
    user = Regexp.last_match[:user]
    power_levels = QiitaScouter::Core.new.analyze(user)
    message = sprintf("ユーザー名: %s 戦闘力: %s 攻撃力: %s 知力: %s すばやさ: %s #qiita_scouter \n#{current_time}", user, *power_levels)
    robert_garcia.tweet(message)
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
    "Tbpgr Qiita |> Ruboty って何？どうやって動かすの？ Hubot と何が違うの？どっちを使えばいいの？ |> http://qiita.com/tbpgr/items/39d93a0a33ec99e37da1 #ruboty",
    "Tbpgr Qiita |> Qiita の記事の見出しに Font-Awesome を利用して見栄えを良くする |> http://qiita.com/tbpgr/items/361d8aaa38fb57d75216 #qiita",
    "Tbpgr Qiita |> Qiitaの特定ユーザー・特定タグの記事をテーブル形式のまとめ記事として生成する QiitaMatome gem を作ってみた |> http://qiita.com/tbpgr/items/36089a184aa0bd7d7954 #qiita",
    "Tbpgr Qiita |> お気に入りのユーザーの記事をすべてストックする Qiita::NekosogiStocker gem を作成した |> http://qiita.com/tbpgr/items/c9eadc1e77e8645824e0 #qiita",
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
    "Tbpgr Qiita |> RuboCop 関連記事 |> https://qiita.com/tbpgr/items/edbfecb6a6789dd54f47 #rubocop",
    "Ruboty のコードリーディングで Ruboty の仕組みを理解すると共に Ruby の設計・実装の定石を学ぶ |> http://qiita.com/tbpgr/items/5887003cd2e69e9d8867 #ruboty",
    "Tbpgr Gems |> ruboty plugin の README を生成する ruboty-megen gem |> https://github.com/tbpgr/ruboty-megen #ruboty",
    "Tbpgr Gems |> ruboty plugin の Qiita 記事を生成する ruboty-articlegen gem |> https://github.com/tbpgr/ruboty-articlegen #ruboty",
    "Tbpgr Gems |> 西暦から和暦を取得する ruboty plugin,  ruboty-wareki gem |> https://github.com/tbpgr/ruboty-wareki #ruboty",
    "Tbpgr Gems |> 西暦から十二支の名称、emoji を取得する ruboty plugin,  ruboty-eto gem |> https://github.com/tbpgr/ruboty-eto #ruboty",
    "Tbpgr Gems |> 西暦から十二支の名称、emoji を取得する eto gem |> https://github.com/tbpgr/eto #ruboty",
    "Tbpgr Gems |> 日付フォーマットのディレクトリ一括作成を行う defoker gem |> https://github.com/tbpgr/defoker",
    "Tbpgr Slides |> 日付フォーマットのディレクトリ一括作成を行う defoker gem スライドショー |> http://tbpgr.github.io/defoker_slide/ #defoker",
    "Tbpgr Slides |> Chrome 拡張 qiita ( ˘ω˘)ﾉ""Y☆Yヾ(˘ω˘ ) twitter スライドショー |> http://bit.ly/1JCB73m",
  ]

  IDLE_TALKS = [
    '|電柱|･ω･`)ﾉ 呼んだ？ ',
    '中の人などいない',
    'インド人を右に',
    'ザンギュラのスーパーウリアッ上',
    'ジャンプ大パチン',
    'もきゅ？',
    'めそ',
    'んばばんばんば、めらっさめらっさ',
    'ここまでなめられては狼牙風風拳をご披露するしかないぜ',
    '森崎くん一歩も動けない！',
    '一堂零・冷越豪・出瀬潔・大間仁・物星大',
    'アイアンダック速射砲',
    'ペッチョチョチョチョリゲス と アンネナプタンポポホフ',
    '豊島？強いよねえ。序盤、中盤、終盤、隙がないと思うよ。だけど…俺は、負けないよ。 え～、こまた・・・駒達が躍動する俺の将棋を皆さんに見せたいね。',
    'あべし ひでぶ たわば へいべ ぷらぼ',
    'ドンゴット理事長',
    'テニスを差した後に電源は付けたままソフトを抜き、スーパーマリオを差す',
    '円ガバス為替レート',
    'ゆうていみやおうきむこうほりいゆうじとりやまあきらぺぺぺぺぺぺぺぺぺぺぺぺぺぺぺぺぺぺぺぺぺぺぺぺぺぺぺ',
    'エンペラー、バーニングサン、アバンテ、ホライズン。どれにしますか？軽量化はしますか？',
    'バンブーアトラス ✕ Danzig のバンダン配合は禁止で',
    '石崎くんの顔面ブロック',
    'スカイラブハリケーンは反則か否か',
    '武闘家もりそば と 賢者うおのめ',
    '冷峰学園は禁止',
    'マッハパンチ、マッハキック、マッハチョップ、マッハ叩き、マッハふみふみ、マッハきうきう、マッハスイング',
    'すがたの爆弾パンチで自滅',
    '↑ ↑ ↓ ↓ ← → ← → B A',
    '↑ ↑ ↓ ↓ ← → ← → select start',
    '小足見てから昇龍余裕でした',
    '＼アリだー！／',
    'ねんがんのアイスソードをてにいれたぞ!',
    '8回連続で逃げた後、永久に会心の一撃',
    'ダッダーン、ボヨヨン ボヨヨン',
    '食う寝る遊ぶ',
    'ごうだのずつきスペシャル',
    'ごだいの棒術スペシャル',
    'くまだの人間魚雷',
    'もよもと',
    'へのつっぱりはいらんですよ',
    '「もうひといきじゃ パワーをメテオに」「いいですとも」',
    '今のはメラゾーマではない…メラだ',
    'クロコダイーーーーン！！'
  ]

  TENYAWANYA_BOT = [
    '@tenyawanya_bot とり',
    '@tenyawanya_bot こんばんは（こんばんわ）',
    '@tenyawanya_bot かわいい',
    '@tenyawanya_bot よくできました',
    '@tenyawanya_bot ちいさい',
    '@tenyawanya_bot すもけ',
    '@tenyawanya_bot おはよう',
    '@tenyawanya_bot おやすみ',
    '@tenyawanya_bot いえーい',
    '@tenyawanya_bot ななちん',
    '@tenyawanya_bot らーめん',
    '@tenyawanya_bot ミラノ風',
    '@tenyawanya_bot たべもの',
    '@tenyawanya_bot おやつ'
  ]

  CHOMADO_BOT = [
    '@chomado_bot ホモ、好きですか？',
    '@chomado_bot BL、好きですか？',
    '@chomado_bot 松牛、好きですか？',
    '@chomado_bot 百合、好きですか？',
    '@chomado_bot 美女、好きですか？',
    '@chomado_bot ｼｮﾀ、好きですか？',
    '@chomado_bot 黒歴史をどうぞ。',
    '@chomado_bot ご主人様をどう思ってますか？',
    '@chomado_bot 落ち込んだ時何をしますか？',
    '@chomado_bot C++ と Python と Ruby ならどれが好きですか？',
    '@chomado_bot 今何時ですか？',
    '@chomado_bot 「ちょまど」ってどういう意味ですか？'
  ]

  SYOBOCHIRN_BOT = [
    '@syobochirn おみくじひいてー'
  ]

  MESSAGES = ADV_MESSAGES + IDLE_TALKS + TENYAWANYA_BOT + SYOBOCHIRN_BOT + CHOMADO_BOT
end

def random_advertise(robert_garcia, twitter_id, tweet)
  return if twitter_id == 'tbpgr_bot'
  return if tweet.include?('@')
  return if rand > 0.2
  robert_garcia.tweet("#{RandomTweet::MESSAGES.sample} \n#{current_time}")
end

robert_garcia = RobertGarcia.new
robert_garcia.stream_client.on_timeline_status do |status|
  begin
    twitter_id = status.user.screen_name
    tweet = status.text
    random_advertise(robert_garcia, twitter_id, tweet)
    # TODO: そのうち使う管理者限定モード
    # author_only(twitter_id, tweet)
    anyone(robert_garcia, twitter_id, tweet)
  rescue => e
    robert_garcia.tweet "bad request #{current_time}"
  end
end

robert_garcia.stream_client.userstream  do |tweet|
end
