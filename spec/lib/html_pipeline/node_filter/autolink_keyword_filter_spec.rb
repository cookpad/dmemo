require "rails_helper"

describe HTMLPipeline::NodeFilter::AutolinkKeywordFilter do
  describe ".call" do
    let(:autolink_keywords) { {
      "ruby" => "https://www.ruby-lang.org/",
      "uby" => "https://example.com/",
    } }
    let(:context) { { autolink_keywords: autolink_keywords } }

    context "with plain text" do
      let(:html) { "<p>This is ruby.</p>" }
      it { expect(described_class.call(html, context: context)).to eq('<p>This is <a href="https://www.ruby-lang.org/">ruby</a>.</p>') }
    end

    context "with anchored html" do
      let(:html) { '<p><a href="https://example.com/">This is ruby</a>.</p>' }
      it { expect(described_class.call(html, context: context)).to eq('<p><a href="https://example.com/">This is ruby</a>.</p>') }
    end
  end
end
