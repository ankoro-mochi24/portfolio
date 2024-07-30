class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_commentable
  before_action :set_comment, only: [:edit, :update, :destroy]

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
        #format.turbo_stream { render :error }
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
        #format.turbo_stream { render :error }
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
  end

  def set_comment
    @comment = Comment.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
