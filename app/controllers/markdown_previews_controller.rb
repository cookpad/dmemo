class MarkdownPreviewsController < ApplicationController
  def create(md)
    @preview = MarkdownPreview.new(md)
  end
end
