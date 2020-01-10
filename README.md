# プレゼント用貯金管理アプリ  

プレゼントを渡したい相手のポストを1つ1つ作り、
Bank（自分の貯金箱）から各ポストにお金振り替えする。
そうすることで、自分のプレゼント口座の管理と、各ポストの口座の管理を行える。

※本来は実際の銀行口座と連携したかったですが、厳しそうだったので仮想口座で妥協しました。

![20200110_214810](https://user-images.githubusercontent.com/47974150/72154744-c8ac6700-33f4-11ea-9583-ce14a7c8f592.GIF)
![20200110_215123](https://user-images.githubusercontent.com/47974150/72154768-dcf06400-33f4-11ea-88df-ef9d29ce66dc.GIF)

# 製作者
+ Tshi66 (https://github.com/Tshi66)
    + ***Wantedly:***(https://www.wantedly.com/users/99532404)  

# 使用した技術
  + 開発環境
      + xcode, swift, xcodeGUIによるGitの操作
  + 画像アップロード
      + realmに保存。（サイズ5MBまでしか対応できない）今後aws or gcpを使用予定。
  + DB
      + Realm
  + バリデーション 
      + Validator(https://github.com/adamwaite/Validator)
  + アプリのチュートリアル画面
      + paper-onboarding(https://github.com/Ramotion/paper-onboarding)
  + 金額を管理するプログレスview
      + MBCircularProgressBar(https://github.com/MatiBot/MBCircularProgressBar)
      
# 今後の開発予定
  + テスト（単体テスト、統合テスト）
  + firestoreを使った画像保存
      
# 主な機能
  + プレゼント管理用ポストの作成、削除、編集
  + ローカル通知の日時指定、時間指定、繰り返し、（必要金額やプレゼントを渡すまでの残り日数）
  + ポストのアバター画像変更
  + 初回起動時にわかりやすいチュートリアルページを表示。
  + Validate（ライブラリ）を使って、バリデーションを実装（金額、空白無効、文字数制限、日付など）
  
# 開発において工夫した点
  + appleのドキュメントをしっかり読む。
  + エラー文をしっかり読む
  + プログラミングの基本を開発と並行して学ぶ
  + swiftの日本語の学習教材が少ない中、英語の教材でなんとか学ぶ。(https://www.udemy.com/course/ios-13-app-development-bootcamp/)
