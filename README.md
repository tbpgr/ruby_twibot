# TbpgrTweet Bot
## 概要
私の Tweet Bot です。

## 目的
定まっていません。

## 機能
### 干支取得機能
* 十二支  
※十二支と年数の間に適当な文字を挟むことが可能。重複ツイート対策。

~~~
# @tbpgr
@tbpgr_bot 十二支 1980
# @tbpgr_bot
西暦1980年の十二支は 申 年
~~~

* 十干十二支  
※十干十二支と年数の間に適当な文字を挟むことが可能。重複ツイート対策。

~~~
# @tbpgr
@tbpgr_bot 十干十二支 1980
# @tbpgr_bot
西暦1980年の十二支は 庚申 年
~~~

### Ruboty ダウンロードランキング機能
「ruboty-」ではじまる gem のダウンロードランキングを表示
1位から9位まで表示可能

※ `ruboty` と `ランキング` の間に適当な文字を挟むことが可能。重複ツイート対策。

* 1位を表示

~~~
# @tbpgr
@tbpgr_bot ruboty ランキング 1
# @tbpgr_bot
Ruboty Download Ranking
No1 ruboty-weather(DL 1272) by Ryoichi SEKIGUCHI
at 2014/12/07 14:57:56
~~~

* 2位を表示

~~~
# @tbpgr
@tbpgr_bot ruboty ランキング 2
# @tbpgr_bot
Ruboty Download Ranking
No2 ruboty-redis(DL 925) by Ryo Nakamura
at 2014/12/07 14:58:01
~~~

### Ruboty ランダム紹介
「ruboty-」ではじまる gem のうち1つをランダムに紹介します。  
gemの説明文などが長い場合、ツイートは140文字で切れます。  

※ `ruboty` と `ランダム` の間に適当な文字を挟むことが可能。重複ツイート対策。

* 試行 1 回目

~~~
# @tbpgr
@tbpgr_bot ruboty ランダム
# @tbpgr_bot
RubotyPluginランダム紹介
ruboty-deadline
ruboty plugin for 〆.
https://github.com/blockgiven/ruboty-deadline …
at 2014/12/07 21:4
~~~

* 試行 1 回目

~~~
# @tbpgr
@tbpgr_bot ruboty 適当な文字列 ランダム
# @tbpgr_bot
RubotyPluginランダム紹介
ruboty-opening_sentence
Ruboty plugin for 小説の書き出し.
https://github.com/blockgiven/ruboty-opening_sente …
~~~

### ランダムツイート
TL にメッセージが来る度に 10 % の確率で RandomTweet::MESSAGES の中からランダムに1つのメッセージをツイートします。
RandomTweet::MESSAGES は

* tbpgr が Qiita に投稿している記事のカテゴリまとめ
* tbpgr が Qiita に投稿している記事の中でストック数の多い記事
* tbpgr が 作成した gem の紹介
* tbpgr が 作成した スライドショー の紹介

などです。

### バージョン
バージョンを確認します

~~~
# @tbpgr
@tbpgr_bot 今のバージョンは？
# @tbpgr_bot
@tbpgr 1.0.0です
~~~

## 補足
* そのうち、 ツイートボットフレームワークを作って置き換えようと思っているので
  現状のプログラムの保守性・拡張性はあまり意識していません。
