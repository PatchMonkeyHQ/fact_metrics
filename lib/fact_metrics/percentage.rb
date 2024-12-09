module FactMetrics::Percentage
    extend ActiveSupport::Concern

    class_methods do
      def percentage(name, uses: :itself, **options)
        scope(data_method_name(name), lambda { select(percentage_sql(name, options)) })

        composed_of composed_of_name(name).to_sym,
          class_name: "Metric",
          mapping: {sql_result_name(name) => :value},
          constructor: proc { |value| Metric.new(value, options.reverse_merge({name: composed_of_name(name), unit: "%"})) }

        metric_hash[data_method_name(name)] = [uses].compact
      end

      def data_method_name(name)
        "#{name}_percentages"
      end

      def composed_of_name(name)
        "#{name}_percentage_metric"
      end

      def sql_result_name(name)
        "#{name}_percentage"
      end

      def field_name(name, options)
        options[:field] || name
      end

      def conditional(name, options)
        if options[:equal]
          "#{field_name(name, options)} = '#{options[:equal]}'"
        elsif options[:in]
          "#{field_name(name, options)} in (#{options[:in].map { |i| "'#{i}'" }.join(",")})"
        elsif options[:condition] && options[:field]
          "#{field_name(name, options)} #{options[:condition]}"
        elsif options[:condition]
          options[:condition].to_s
        elsif options[:all]
          "true"
        else
          raise "Conditional option ([:equal, :in, :condition, :all]) required to determine percentage."
        end
      end

      def denominator_sql(name, options)
        if options[:denominator] == :all
          "COUNT(*)"
        elsif options[:denominator]
          "MAX(#{options[:denominator]})"
        else
          "SUM(CASE WHEN #{field_name(name, options)} IS NOT NULL THEN 1 END)"
        end
      end

      def percentage_sql(name, options)
        <<~SQL
          ROUND(
            (
              (COUNT(*) FILTER (WHERE #{conditional(field_name(name, options), options)}))::decimal
              /
              NULLIF(#{denominator_sql(name, options)}, 0)
            ) * 100,
            2
          ) AS #{sql_result_name(name)}
        SQL
      end
    end
  end
