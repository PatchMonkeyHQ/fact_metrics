class FactMetrics::PercentageConfig
  attr_reader :name, :uses, :options

  def initialize(name, uses: nil, **options)
    @name = name
    @uses = uses
    @options = options
  end

  def scope_name = "#{name}_percentages"
  def sql_result_name = "#{name}_percentage"
  def composed_of_name = "#{name}_percentage_metric"

  def composed_of_attributes
    [
      composed_of_name.to_sym,
      class_name: "Metric",
      mapping: {sql_result_name => :value},
      constructor: proc { |value| FactMetrics::Metric.new(value, metric_options) }
    ]
  end

  def sql
    <<~SQL
      ROUND(
        (
          CAST(COUNT(*) FILTER (WHERE #{condition_sql}) AS DECIMAL)
          /
          NULLIF(#{denominator_sql}, 0)
        ) * 100,
        2
      ) AS #{sql_result_name}
    SQL
  end

  def condition_sql
    if options[:equal]
      "#{field_name} = '#{options[:equal]}'"
    elsif options[:in]
      "#{field_name} IN (#{options[:in].map { |i| "'#{i}'" }.join(",")})"
    elsif options[:condition] && options[:field]
      "#{field_name} #{options[:condition]}"
    elsif options[:condition]
      options[:condition].to_s
    elsif options[:all]
      "true"
    else
      raise "Conditional option ([:equal, :in, :condition, :all]) required to determine percentage."
    end
  end

  def denominator_sql
    if options[:denominator] == :all
      "COUNT(*)"
    elsif options[:denominator]
      "MAX(#{options[:denominator]})"
    else
      "SUM(CASE WHEN #{field_name} IS NOT NULL THEN 1 END)"
    end
  end

  def field_name
    options[:field] || name
  end

  def metric_options
    {name: composed_of_name, unit: "%"}.merge(options)
  end
end
