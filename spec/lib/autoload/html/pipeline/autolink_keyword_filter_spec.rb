require "rails_helper"

describe HTML::Pipeline::AutolinkKeywordFilter do
  describe "#call" do
    let(:filter) { HTML::Pipeline::AutolinkKeywordFilter.new(doc, autolink_keywords: autolink_keywords) }
    let(:doc) { Nokogiri::HTML::DocumentFragment.parse(html) }
    let(:autolink_keywords) { {
      "ruby" => "https://www.ruby-lang.org/",
      "uby" => "https://example.com/",
    } }

    context "with plain text" do
      let(:html) { "This is ruby." }
      it { expect(filter.call).to eq('This is <a href="https://www.ruby-lang.org/">ruby</a>.') }
    end

    context "with anchored html" do
      let(:html) { '<a href="https://example.com/">This is ruby</a>.' }
      it { expect(filter.call).to eq('<a href="https://example.com/">This is ruby</a>.') }
    end
  end
end
