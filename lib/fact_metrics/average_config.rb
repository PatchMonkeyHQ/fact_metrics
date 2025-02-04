class FactMetrics::AverageConfig
  attr_reader :name, :uses, :options

  def initialize(name, uses: nil, **options)
    @name = name
    @uses = uses
    @options = options
  end

  def scope_name = "#{name}_averages"

  def sql_result_name = "average_#{name}"

  def composed_of_name = "average_#{name}_metric"

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
      CASE WHEN count(*) != 0 THEN
        AVG(#{field_name})
      END AS #{sql_result_name}
    SQL
  end

  def field_name
    options[:field] || name.to_s
  end

  def metric_options
    options.merge({name: composed_of_name})
  end
end
