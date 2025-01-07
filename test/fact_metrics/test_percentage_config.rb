require "test_helper"

class FactMetricsPercentageConfigTest < ActiveSupport::TestCase
  def test_scope_name
    config = FactMetrics::PercentageConfig.new(:example)

    assert_equal "example_percentages", config.scope_name
  end

  def test_sql_result_name
    config = FactMetrics::PercentageConfig.new(:example)

    assert_equal "example_percentage", config.sql_result_name
  end

  def test_composed_of_name
    config = FactMetrics::PercentageConfig.new(:example)

    assert_equal "example_percentage_metric", config.composed_of_name
  end

  def test_condition_sql_with_equal_and_field_option
    config = FactMetrics::PercentageConfig.new(:example, equal: 5, field: :other_field)

    assert_equal "other_field = '5'", config.condition_sql
  end

  def test_condition_sql_with_in_option
    config = FactMetrics::PercentageConfig.new(:example, in: [5..10], field: :other_field)

    assert_equal "other_field IN ('5..10')", config.condition_sql
  end

  def test_condition_sql_with_condition_and_field_options
    condition = "= 2"
    field = "other_field"
    config = FactMetrics::PercentageConfig.new(:example, condition: condition, field: field)

    assert_equal "#{field} #{condition}", config.condition_sql
  end

  def test_condition_sql_with_condition_option
    condition = "field = 2"
    config = FactMetrics::PercentageConfig.new(:example, condition: condition)

    assert_equal condition, config.condition_sql
  end

  def test_condition_sql_with_all_option
    config = FactMetrics::PercentageConfig.new(:example, all: true)

    assert_equal "true", config.condition_sql
  end

  def test_condition_sql_without_option
    config = FactMetrics::PercentageConfig.new(:example)

    error = assert_raises(RuntimeError) { config.condition_sql }
    assert_equal "Conditional option ([:equal, :in, :condition, :all]) required to determine percentage.", error.message
  end

  def test_denominator_sql_with_all_option
    config = FactMetrics::PercentageConfig.new(:example, denominator: :all)

    assert_equal "COUNT(*)", config.denominator_sql
  end

  def test_denominator_sql_with_field_name
    config = FactMetrics::PercentageConfig.new(:example, denominator: "other_field_name")

    assert_equal "MAX(other_field_name)", config.denominator_sql
  end

  def test_denominator_sql_without_option
    config = FactMetrics::PercentageConfig.new(:example)

    assert_equal "SUM(CASE WHEN example IS NOT NULL THEN 1 END)", config.denominator_sql
  end

  def test_sql
    config = FactMetrics::PercentageConfig.new(:example, all: true)

    expected_sql = <<~SQL
      ROUND(
        (
          CAST(COUNT(*) FILTER (WHERE true) AS FLOAT)
          /
          NULLIF(SUM(CASE WHEN example IS NOT NULL THEN 1 END), 0)
        ) * 100,
        2
      ) AS example_percentage
    SQL

    assert_equal expected_sql, config.sql
  end

  def test_metric_options
    config = FactMetrics::PercentageConfig.new(:example, all: true)

    expected_options = { all: true, name: "example_percentage_metric", unit: "%" }
    assert_equal expected_options, config.metric_options
  end

  def test_composed_of_attributes
    config = FactMetrics::PercentageConfig.new(:example, all: true)

    name, hsh = config.composed_of_attributes

    assert_equal :example_percentage_metric, name
    assert_equal "Metric", hsh[:class_name]
    assert_equal({ "example_percentage" => :value }, hsh[:mapping])

    metric = hsh[:constructor].call
    assert_nil metric.value
    assert_equal "example_percentage_metric", metric.options[:name]
    assert_equal "%", metric.options[:unit]
    assert_equal true, metric.options[:all]
  end
end
