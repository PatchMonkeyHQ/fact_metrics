class FactMetrics::Metric
  attr_reader :value, :options

  BLANK = Class.new do
    def method_missing(m, *args, &block)
      if respond_to_missing?(m)
        Metric.new(0, {precision: 0})
      end
    end

    def respond_to_missing?(m)
      /_metric$/.match?(m)
    end
  end

  def initialize(value, options)
    @value, @options = value, options
  end

  def name
    options[:name].humanize
  end

  def display_value
    (value || 0).round(precision)
  end

  def precision
    options[:precision] || 1
  end

  def unit
    options[:unit] || ""
  end
end
