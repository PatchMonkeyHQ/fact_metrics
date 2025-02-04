require "test_helper"

class PercentageMockModel
  include FactMetrics

  def self.scope(*args)
    @@scope_args = args
  end

  def self.composed_of(*args)
    @@composed_of_args = args
  end

  def scope_args
    @@scope_args
  end

  def composed_of_args
    @@composed_of_args
  end

  percentage :paid
end

class FactMetricsPercentageTest < Minitest::Test
  def test_percentage_calls_scope
    @mock = PercentageMockModel.new

    assert_equal "paid_percentages", @mock.scope_args[0]
  end

  def test_percentage_calls_composed_of
    @mock = PercentageMockModel.new

    assert_equal :paid_percentage_metric, @mock.composed_of_args[0]
  end

  def test_adds_scope_to_metric_hash
    @mock = PercentageMockModel.new

    assert_equal "paid_percentages", @mock.metric_hash.keys.first
  end
end
