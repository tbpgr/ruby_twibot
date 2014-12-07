# TbpgrTweet Bot
## 概要
私の Tweet Bot です。

## 目的
定まっていません。

## 機能
### 干支取得機能
* 十二支

~~~
# @tbpgr
@tbpgr_bot 十二支 1980
# @tbpgr_bot
西暦1980年の十二支は 申 年
~~~

* 十干十二支

~~~
# @tbpgr
@tbpgr_bot 十干十二支 1980
# @tbpgr_bot
西暦1980年の十二支は 庚申 年
~~~

### Ruboty ダウンロードランキング機能
「ruboty-」ではじまる gem のダウンロードランキングを表示
1位から9位まで表示可能

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

## 補足
* 今のところ私自身以外のツイートには反応しません
* そのうち、 ruboty + ruboty-twitter adapter に乗り換えようと思っているので
  現状のプログラムの保守性・拡張性はあまり意識していません。
