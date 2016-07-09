module HTML
  class Pipeline
    class InnerTextFilter < HTML::Pipeline::Filter
      def call
        doc.text
      end
    end
  end
end
