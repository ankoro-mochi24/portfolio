class CommentsController < ApplicationController
  before_action :authenticate_user!, only: [:create, :destroy]
  before_action :set_commentable, only: [:create, :destroy]
  before_action :set_comment, only: [:destroy]

  def create
    @comment = @commentable.comments.new(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to @commentable, notice: 'Comment was successfully created.'
    else
      redirect_to @commentable, alert: 'Failed to create comment.'
    end
  end

  def destroy
    if @comment.user == current_user
      @comment.destroy
      redirect_to @commentable, notice: 'Comment was successfully deleted.'
    else
      redirect_to @commentable, alert: 'You can only delete your own comments.'
    end
  end

  private

  def set_commentable
    @commentable = if params[:recipe_id]
                     Recipe.find(params[:recipe_id])
                   elsif params[:food_id]
                     Food.find(params[:food_id])
                   end
  end

  def set_comment
    @comment = @commentable.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
