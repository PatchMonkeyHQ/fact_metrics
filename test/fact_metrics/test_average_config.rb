require "test_helper"

class FactMetricsAverageConfigTest < ActiveSupport::TestCase
  def test_scope_name
    average = FactMetrics::AverageConfig.new(:example)

    assert_equal "example_averages", average.scope_name
  end

  def test_sql_result_name
    average = FactMetrics::AverageConfig.new(:example)

    assert_equal "average_example", average.sql_result_name
  end

  def test_composed_of_name
    average = FactMetrics::AverageConfig.new(:example)

    assert_equal "average_example_metric", average.composed_of_name
  end

  def test_field_name_with_field_option
    field_name = "other_name"
    average = FactMetrics::AverageConfig.new(:example, field: field_name)

    assert_equal field_name, average.field_name
  end

  def test_field_name_without_field_option
    average = FactMetrics::AverageConfig.new(:example)

    assert_equal "example", average.field_name
  end

  def test_sql
    average = FactMetrics::AverageConfig.new(:example)

    expected_sql = <<~SQL
      CASE WHEN count(*) != 0 THEN
        AVG(example)
      END AS average_example
    SQL

    assert_equal expected_sql, average.sql
  end

  def test_metric_options
    average = FactMetrics::AverageConfig.new(:example)

    expected_options = {name: "average_example_metric"}
    assert_equal expected_options, average.metric_options
  end

  def test_composed_of_attributes
    average = FactMetrics::AverageConfig.new(:example)

    name, hsh = average.composed_of_attributes

    assert_equal :average_example_metric, name
    assert_equal "Metric", hsh[:class_name]
    assert_equal({"average_example" => :value}, hsh[:mapping])

    metric = hsh[:constructor].call
    assert_nil metric.value
    assert_equal "average_example_metric", metric.options[:name]
  end
end
