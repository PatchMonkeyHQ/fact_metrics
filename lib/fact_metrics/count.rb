module FactMetrics::Count
  extend ActiveSupport::Concern

  class_methods do
    def count(name, uses: nil, **options)
      count_config = FactMetrics::CountConfig.new(name, **options)

      scope(count_config.scope_name, -> { select(count_config.sql) })
      composed_of(*count_config.composed_of_attributes)

      metric_hash[count_config.scope_name] = [count_config.uses].compact
    end
  end
end
