# frozen_string_literal: true

require_relative "fact_metrics/version"
require_relative "fact_metrics/average"
require_relative "fact_metrics/count"
require_relative "fact_metrics/percentage"
require_relative "fact_metrics/average_config"
require_relative "fact_metrics/count_config"
require_relative "fact_metrics/percentage_config"
require_relative "fact_metrics/metric"
require "active_support/concern"

module FactMetrics
  class Error < StandardError; end
  extend ActiveSupport::Concern

  included do
    class_attribute :metric_hash, default: {}
  end

  include Average
  include Count
  include Percentage

  class_methods do
    def all_metrics
      load_metrics(*metric_hash.keys)
    end

    def load_metrics(*metrics)
      metrics = metrics.map(&:to_s)
      metric_prerequisites = metrics.flat_map { |metric| metric_hash.fetch(metric) }.compact.uniq
      metric_query = (metric_prerequisites + metrics).inject(self) { |model_klass, metric_method| model_klass.send(metric_method) }

      # ActiveRecord short-circuits "impossible" predicates, returning an empty array.
      # In aggregation queries, however, results can still be meaningful without matching rows.
      # To ensure the query executes, replace the conditional with one that cannot be short-circuited.
      if metric_query.where_clause.contradiction?
        metric_query.where_clause = ActiveRecord::Relation::WhereClause.empty
        metric_query.where!("1=0")
      end

      metric_query
    end
  end
end
