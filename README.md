# glaz_ai

## これはなんですか？

https://twitter.com/_glaz_ai を管理する為のプログラムです。

## 各ファイルについて
- .gitignore

 必要ないファイルをgitの管理から外します。

- README.md

 今みているファイルを記述しているファイルです。

- configparser.jl

 configファイルを管理する為のjuliaソースコードです。

- main.jl

 Twitterにツイートする為の機能を持ったメインのプログラムです。

- main_not_tweet.jl

 Twitterにツイートしないメインのプログラムです。
 文章生成の確認の為に使用することが出来ます。

- tweet.jl

 twitterAPIを使う為のjuliaソースコードです。
 
## *.iniについて
### api.iniの書き方

api.iniはTwitterAPIを管理する為のファイルです。
以下の通り記述してください。

```
[OAuth]
consumer_key = CK
consumer_secret = CS
access_token_key = AK
access_token_secret = AS

[User]
user_id = UI
```

それぞれ大文字二文字になっているところに対応するものを入力してください。

user_idは@で区切る事によって複数入力する事が可能です。

### bot.iniの書き方
bot.iniはbotを管理する為のファイルです。以下の通り記述してください。

```
[CONF]
num = 3
time = 1200
```
unmは連結数、timeはツイート更新秒数を指定します。
