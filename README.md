# [プレゼント管理アプリ](https://apps.apple.com/jp/app/%E3%83%97%E3%83%AC%E3%82%BC%E3%83%B3%E3%83%88%E7%AE%A1%E7%90%86/id1497484818)
<img width="728" alt="スクリーンショット 2020-02-05 23 00 48" src="https://user-images.githubusercontent.com/47974150/73848915-5cdee200-486c-11ea-9b05-2781c07234f1.png">

ポストを1つ1つ作り、プレゼントの予定日や予算などを管理できるアプリです。

#

![20200110_214810](https://user-images.githubusercontent.com/47974150/72154744-c8ac6700-33f4-11ea-9583-ce14a7c8f592.GIF)
![20200205_224959](https://user-images.githubusercontent.com/47974150/73849300-0faf4000-486d-11ea-8fb8-12584f02fe38.GIF)
![20200205_224814](https://user-images.githubusercontent.com/47974150/73849264-fc9c7000-486c-11ea-849e-737aaf1c8ec3.GIF)
![20200205_225047](https://user-images.githubusercontent.com/47974150/73849385-2d7ca500-486d-11ea-9238-325325aaf797.GIF)


# プロジェクトのクローンからビルド完了までの手順

### bundlerでcocoapodsをバージョン管理しています。
```
 *version
 
 Bundler '1.17.2'
 Cocoapods '1.8.4'
```
### クローンからビルド完了までの手順
1. このプロジェクトをclone or download

2. ```$ bundle install --path vendor/bundle```

3. ```$ bundle exec pod install```


### エラーが出る場合
1. ```$ bundle exec pod --version```で、’1.8.4’であるか確認して下さい。
2. ```$ gem list | grep 'bundler'```で、**bundlerがインストール**されているか確認してください。


# 使用した技術
  + 開発環境
      + xcode, swift 
  + DB
      + Realm, UserDefaults
  + ローカル通知
      + UserNotification
  + バリデーション 
      + [Validator](https://github.com/adamwaite/Validator)
  + アプリのチュートリアル画面
      + [paper-onboarding](https://github.com/Ramotion/paper-onboarding)
  + 金額のプログレス表示
      + [MBCircularProgressBar](https://github.com/MatiBot/MBCircularProgressBar)
  + 画像トリミング
      + [TOCropViewController](https://github.com/TimOliver/TOCropViewController)
  + アニメーション
    + [Lottie-ios](https://github.com/airbnb/lottie-ios)
  + トースト（ポップアップアラート）
    + [Loaf](https://github.com/schmidyy/Loaf)
      
# 主な機能
  + プレゼント管理用ポストの作成、削除、編集
  + ローカル通知の日時指定、時間指定、繰り返し、（必要金額やプレゼントを渡すまでの残り日数）
  + 画像のトリミング
  + 初回起動時にわかりやすいチュートリアルページを表示
  + Validate（ライブラリ）を使って、バリデーションを実装（金額、空白無効、文字数制限、日付など）
  + アニメーションやトーストで可愛いUIへ
  
# デザインツール

AdobeXD
→[作成したプロトタイプ](https://xd.adobe.com/view/170dd0bc-ee66-4eb9-7f09-06548c65ce7f-613c/?fullscreen&hints=off)
以下のようにデザインを行いました。
<img width="985" alt="スクリーンショット 2020-02-05 23 47 26" src="https://user-images.githubusercontent.com/47974150/73852151-0d9bb000-4872-11ea-8bbf-0e98bab13a02.png">
