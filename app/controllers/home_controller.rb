class HomeController < ApplicationController
  before_action :set_layout, only: [:top]

  def top
  end

  def cookrice
  end

  private

  def set_layout
    @use_split_layout = true
  end
end
