class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_commentable, only: [:create]
  before_action :set_comment, only: [:update, :destroy]
  before_action :authorize_user, only: [:update, :destroy]

  def create
    @comment = @commentable.comments.build(comment_params)
    @comment.user = current_user
    if @comment.save
      respond_to do |format|
        format.html { redirect_back fallback_location: root_path, notice: 'コメントが追加されました。' }
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html { redirect_back fallback_location: root_path, alert: 'コメントの追加に失敗しました。' }
        format.turbo_stream { render :error }
      end
    end
  end

  def update
    if @comment.update(comment_params)
      respond_to do |format|
        format.html { redirect_back fallback_location: root_path, notice: 'コメントが更新されました。' }
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html { redirect_back fallback_location: root_path, alert: 'コメントの更新に失敗しました。' }
        format.turbo_stream { render :error }
      end
    end
  end

  def destroy
    @comment.destroy
    respond_to do |format|
      format.html { redirect_back fallback_location: root_path, notice: 'コメントが削除されました。' }
      format.turbo_stream
    end
  end

  private

  def set_commentable
    @commentable = params[:commentable_type].constantize.find(params[:commentable_id])
  rescue NameError, ActiveRecord::RecordNotFound => e
    Rails.logger.warn("不正なリクエスト: #{e.message}")
    redirect_back fallback_location: root_path, alert: '不正なリクエストです。'
  end

  def set_comment
    @comment = Comment.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_back fallback_location: root_path, alert: 'コメントが見つかりません。'
  end

  def authorize_user
    unless @comment.user == current_user
      redirect_back fallback_location: root_path, alert: '他のユーザーのコメントを編集・削除することはできません。'
    end
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
