module FactMetrics::Count
  extend ActiveSupport::Concern

  class_methods do
    def count(name, uses: nil, **options)
      data_method_name = "#{name}_counts"
      sql_result_name = "#{name}_count"
      composed_of_name = "#{sql_result_name}_metric"

      scope(data_method_name, lambda { select(count_sql(name, sql_result_name, options)) })

      composed_of composed_of_name.to_sym,
        class_name: "Metric",
        mapping: {sql_result_name => :value},
        constructor: proc { |value| Metric.new(value, options.reverse_merge({name: composed_of_name, precision: 0})) }

      metric_hash[data_method_name] = [uses].compact
    end

    def count_sql(name, sql_result_name, options)
      <<~SQL
        COUNT(*) FILTER (WHERE #{condition_sql(name, options)}) AS #{sql_result_name}
      SQL
    end

    def condition_sql(name, options)
      if options[:all] == true
        options[:all].to_s
      elsif options[:equal].present?
        "#{options[:field] || name} = '#{options[:equal]}'"
      elsif options[:condition].present?
        options[:condition].to_s
      end
    end
  end
end
