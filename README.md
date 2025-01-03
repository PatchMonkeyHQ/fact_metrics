# FactMetrics

FactMetrics provides a collection of class methods for defining metrics on Fact
models.

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add fact_metrics
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install fact_metrics
```

## Usage

In your Fact model you can add the following types of metric definitions.

### Counts

```
  count :sales_quantity, all: true
```

### Averages

```
  average :regular_unit_price
```

### Percentages

```
  percentage :received, field: quantity_received, condition: "> 0"
  percentage :inspected, field: quantity_inspected, condition: "> 0"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/PatchMonkeyHQ/fact_metrics.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
