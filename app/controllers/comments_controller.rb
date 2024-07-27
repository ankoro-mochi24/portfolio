class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_commentable
  before_action :set_comment, only: [:edit, :update, :destroy]

  def create
    @comment = @commentable.comments.build(comment_params)
    @comment.user = current_user
    if @comment.save
      redirect_back fallback_location: root_path, notice: 'コメントが追加されました。'
    else
      redirect_back fallback_location: root_path, alert: 'コメントの追加に失敗しました。'
    end
  end

  def update
    if @comment.update(comment_params)
      redirect_back fallback_location: root_path, notice: 'コメントが更新されました。'
    else
      redirect_back fallback_location: root_path, alert: 'コメントの更新に失敗しました。'
    end
  end

  def destroy
    @comment.destroy
    redirect_back fallback_location: root_path, notice: 'コメントが削除されました。'
  end

  private

  def set_commentable
    @commentable = if params[:recipe_id]
                     Recipe.find(params[:recipe_id])
                   elsif params[:foodstuff_id]
                     Foodstuff.find(params[:foodstuff_id])
                   end
  end

  def set_comment
    @comment = Comment.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
