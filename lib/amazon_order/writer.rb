module AmazonOrder
  class Writer
    def initialize(file_glob_pattern, options = {})
      @file_glob_pattern = file_glob_pattern
      @output_dir = options.fetch(:output_dir, 'tmp')
    end

    def print_orders
      data['orders']
    end

    def print_products
      data['products']
    end

    def generate_csv
      require 'csv'
      FileUtils.mkdir_p(@output_dir)
      %w[orders products].map do |resource|
        next if data[resource].blank?
        csv_file = "#{@output_dir}/#{resource}.csv"
        puts "    Writing #{csv_file}"
        CSV.open(csv_file, 'wb') do |csv|
          csv << attributes_for(resource)
          data[resource].each { |r| csv << r }
        end
        csv_file
      end
    end

    def generate_json
      require 'json'
      FileUtils.mkdir_p(@output_dir)
      %w[orders products].map do |resource|
        next if data[resource].blank?
        file = "#{@output_dir}/amazon-#{resource}.json"
        puts "    Writing #{file}"
        output = data[resource]
        File.write(file, output.to_json)
        file
      end
    end

    private

    def data
      @_data ||= begin
        data = {'orders' => [], 'products' => []}
        Dir.glob(@file_glob_pattern).each do |filepath|
          puts "    Parsing #{filepath}"
          parser = AmazonOrder::Parser.new(filepath)
          data['orders'] += parser.orders
          data['products'] += parser.orders.map(&:products).flatten
        end
        # Ensure that duplicate HTML pages don't create duplicate data
        data['orders'] = data['orders'].uniq { |o| o.order_number }
        data['products'] = data['products'].uniq { |o| [ o.order_number, o.title] }
        data
      end
    end

    def attributes_for(resource)
      case resource
      when 'orders'
        AmazonOrder::Parsers::Order::ATTRIBUTES
      when 'products'
        AmazonOrder::Parsers::Product::ATTRIBUTES
      end
    end
  end
end
