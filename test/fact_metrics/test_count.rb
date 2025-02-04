require "test_helper"

class CountMockModel
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

  count :all
end

class FactMetricsCountTest < Minitest::Test
  def test_count_calls_scope
    @mock = CountMockModel.new

    assert_equal "all_counts", @mock.scope_args[0]
  end

  def test_count_calls_composed_of
    @mock = CountMockModel.new

    assert_equal :all_count_metric, @mock.composed_of_args[0]
  end

  def test_adds_scope_to_metric_hash
    @mock = CountMockModel.new

    assert_equal "all_counts", @mock.metric_hash.keys.first
  end
end
