require "test_helper"

class MockModel
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

  average :revenue
end

class FactMetricsAverageTest < Minitest::Test
  def test_average_calls_scope
    @mock = MockModel.new

    assert_equal "revenue_averages", @mock.scope_args[0]
  end

  def test_average_calls_composed_of
    @mock = MockModel.new

    assert_equal :average_revenue_metric, @mock.composed_of_args[0]
  end

  def test_adds_scope_to_metric_hash
    @mock = MockModel.new

    assert_equal "revenue_averages", @mock.metric_hash.keys.first
  end
end
