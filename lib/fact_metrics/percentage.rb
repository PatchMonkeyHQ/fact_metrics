module FactMetrics::Percentage
  extend ActiveSupport::Concern

  class_methods do
    def percentage(name, uses: :itself, **options)
      percentage_config = FactMetrics::PercentageConfig.new(name, uses: uses, **options)

      scope(percentage_config.scope_name, -> {select(percentage_config.sql)} )
      composed_of(*percentage_config.composed_of_attributes)

      metric_hash[percentage_config.scope_name] = [percentage_config.uses].compact
    end
  end
end
