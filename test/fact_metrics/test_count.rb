require "test_helper"

class FactMetricsCountTest < ActiveSupport::TestCase
  class TestModel
    include FactMetrics::Count

    def self.scope(name, body)
      @scopes ||= {}
      @scopes[name] = body
    end

    def self.scopes
      @scopes || {}
    end

    def self.composed_of(name, **_args)
      @composed_metrics ||= []
      @composed_metrics << name
    end

    def self.composed_metrics
      @composed_metrics || []
    end

    def self.metric_hash
      @metric_hash ||= {}
    end
  end
end
