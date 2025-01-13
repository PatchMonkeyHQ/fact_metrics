require "active_support/concern"

module FactMetrics::Average
  extend ActiveSupport::Concern

  class_methods do
    def average(name, uses: nil, **options)
      average_config = FactMetrics::AverageConfig.new(name, uses: uses, **options)

      scope(average_config.scope_name, -> {select(average_config.sql)} )
      composed_of(*average_config.composed_of_attributes)

      metric_hash[average_config.scope_name] = [average_config.uses].compact
    end
  end
end
