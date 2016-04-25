require 'rails_helper'

describe MarkdownDescriptionDecorator do
  let(:markdown_description) { MarkdownDescription.new.extend MarkdownDescriptionDecorator }
  subject { markdown_description }
  it { should be_a MarkdownDescription }
end
