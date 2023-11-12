# frozen_string_literal: true

class AuthorsController < ApplicationController
  def show
    @author = Author.find(params[:id])
    @posts = @author.author_posts(@author.external_uid) || []
  end
end
