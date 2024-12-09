module FactMetrics::Average
  extend ActiveSupport::Concern

  class_methods do
    def average(name, uses: nil, **options)
      data_method_name = "#{name}_averages"
      sql_result_name = "average_#{name}"
      composed_of_name = "average_#{name}_metric"

      scope(data_method_name, lambda { select(average_sql(name, sql_result_name, options)) })

      composed_of composed_of_name.to_sym,
        class_name: "Metric",
        mapping: {sql_result_name => :value},
        constructor: proc { |value| Metric.new(value, options.merge({name: composed_of_name})) }

      metric_hash[data_method_name] = [uses].compact
    end

    def average_sql(name, sql_result_name, options)
      <<~SQL
        CASE WHEN count(*) != 0 THEN
          AVG(#{options[:field] || name})
        END AS #{sql_result_name}
      SQL
    end
  end
end
