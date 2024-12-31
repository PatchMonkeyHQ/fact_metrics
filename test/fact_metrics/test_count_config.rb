require "test_helper"

class FactMetricsCountConfigTest < ActiveSupport::TestCase
  def test_scope_name
    count = FactMetrics::CountConfig.new(:example)

    assert_equal "example_counts", count.scope_name
  end

  def test_sql_result_name
    count = FactMetrics::CountConfig.new(:example)

    assert_equal "example_count", count.sql_result_name
  end

  def test_composed_of_name
    count = FactMetrics::CountConfig.new(:example)

    assert_equal "example_count_metric", count.composed_of_name
  end

  def test_that_condition_returns_true_with_all_option
    count = FactMetrics::CountConfig.new(:example, all: true)

    assert_equal "true", count.condition_sql
  end

  def test_that_condition_uses_other_field_with_equality
    count = FactMetrics::CountConfig.new(:example, equal: 5, field: :other_field)

    assert_equal "other_field = '5'", count.condition_sql
  end

  def test_that_condition_uses_name_with_equality
    count = FactMetrics::CountConfig.new(:example, equal: 5)

    assert_equal "example = '5'", count.condition_sql
  end

  def test_that_condition_uses_condition_option
    condition = "field = 2"
    count = FactMetrics::CountConfig.new(:example, condition: condition)

    assert_equal condition, count.condition_sql
  end

  def test_sql
    count = FactMetrics::CountConfig.new(:example, all: true)

    assert_equal "COUNT(*) FILTER (WHERE true) AS example_count\n", count.sql
  end

  def test_that_metric_options_merge_additional_values
    count = FactMetrics::CountConfig.new(:example, all: true)

    expected_options = { all: true, name: "example_count_metric", precision: 0 }
    assert_equal expected_options, count.metric_options
  end

  def test_composed_of_attributes
    count = FactMetrics::CountConfig.new(:example, all: true)

    name, hsh = count.composed_of_attributes

    assert_equal :example_count_metric, name
    assert_equal "Metric", hsh[:class_name]
    assert_equal({ "example_count" => :value }, hsh[:mapping])

    metric = hsh[:constructor].call
    assert_nil metric.value
    assert_equal "example_count_metric", metric.options[:name]
    assert_equal 0, metric.options[:precision]
    assert_equal true, metric.options[:all]
  end
end

