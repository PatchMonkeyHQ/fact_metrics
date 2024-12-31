class FactMetrics::CountConfig
  attr_reader :name, :uses, :options

  def initialize(name, uses: nil, **options)
    @name = name
    @uses = options["uses"] || nil
    @options = options
  end

  def scope_name = "#{name}_counts"
  def sql_result_name = "#{name}_count"
  def composed_of_name = "#{sql_result_name}_metric"

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
      COUNT(*) FILTER (WHERE #{condition_sql}) AS #{sql_result_name}
    SQL
  end

  def condition_sql
    if options[:all] == true
      options[:all].to_s
    elsif options[:equal].present?
      "#{options[:field] || name} = '#{options[:equal]}'"
    elsif options[:condition].present?
      options[:condition].to_s
    end
  end

  def metric_options
    {name: composed_of_name, precision: 0}.merge(options)
  end
end
