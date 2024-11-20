class FoodstuffImageUploader < CarrierWave::Uploader::Base
  before :remove, :delete_empty_upstream_dirs

  # 画像へのアクセスをアップロード者と管理者に制限
  permissions 0600
  directory_permissions 0700

  if Rails.env.production?
    storage :fog   # 本番環境ではS3に保存
  else
    storage :file  # ローカルではファイルシステムに保存
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  #ファイルサイズ制限による不正アップロードの防止
  def size_range
    1..(5.megabytes)
  end

  # 拡張子の限定によるセキュリティ対策
  def extension_allowlist
    %w(jpg jpeg gif png)
  end

  # ファイルの衝突回避
  # 一意のファイル名を生成する
  def filename
    "#{secure_token}.#{file.extension}"
  end

  # ファイルが空のディレクトリを自動削除
  def delete_empty_upstream_dirs
    path = ::File.expand_path(store_dir, root)
    Dir.delete(path) if Dir.exist?(path) && Dir.empty?(path) # 空のディレクトリが存在する場合のみ削除
  rescue SystemCallError
    true
  end

  protected

  # 一意のトークンを生成するメソッド
  def secure_token
    model.instance_variable_get("@#{mounted_as}_secure_token") || model.instance_variable_set("@#{mounted_as}_secure_token", SecureRandom.uuid)
  end
end
