module AmazonOrder
  module Parsers
    class Product < Base
      ATTRIBUTES = %w[
                     title
                     path
                     content
                     image_url
                     order_number
                   ]

      def title
        @_title ||= @node.css('.a-col-right .a-row')[0].text.strip
      end

      def path
        @_path ||= @node.css('.a-col-right .a-row a')[0].attr('href') rescue nil
      end

      def content
        @_content ||= @node.css('.a-col-right .a-row')[1..-1].map(&:text).join.gsub(/\s+/, ' ').strip
      end

      def image_url
        @_image_url ||= begin
          img = @node.css('.a-col-left img')[0]
          get_original_image_url(img.attr('data-a-hires').presence || img.attr('src'))
        end
      end

      def order_number
        @order_number
      end
    end
  end
end
