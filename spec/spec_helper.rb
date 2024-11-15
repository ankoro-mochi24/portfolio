# RSpecの基本設定をまとめたファイル
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true # カスタムマッチャーのエラー内容を詳細に表示
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true # テスト用オブジェクトに対して存在しないメソッドが呼ばれた場合にエラーを出す設定
  end

  config.before(:suite) do
    ActiveSupport::TestCase.parallelize(workers: :number_of_processors) # CPUの数だけテストを平行処理
  end

  # :focusタグがついたテストだけを優先的に実行する設定
  #  config.filter_run_when_matching :focus

  # rspec --only-failuresコマンドで前回失敗したテストだけを再度実行できる
  config.example_status_persistence_file_path = "spec/examples.txt"

  # トップレベルのdescribe/contextにRSpec.の記述を必須とする設定
  config.disable_monkey_patching!

  # テストの内容がdoc形式で読みやすい説明文として出力される
  # doc形式で結果が表示されるのは、if config.files_to_run.one? の条件により「1つのテストファイルを指定して実行した場合」に限られる
  config.default_formatter = "doc" if config.files_to_run.one?

  # 最も時間のかかったテストを上位10件まで表示し、どのテストが遅いか確認できる
  config.profile_examples = 10

  # テストを毎回ランダムな順番で実行し、順番による不具合がないか確認する
  config.order = :random

  # 上記のランダムな順番を固定することで、特定の順番で問題が発生した際に再現が可能になる
  Kernel.srand config.seed
end
