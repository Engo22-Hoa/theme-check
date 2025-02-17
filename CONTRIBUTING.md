# Contributing to Theme Check

We love receiving pull requests!

For your contribution to be accepted you will need to sign the [Shopify Contributor License Agreement (CLA)](https://cla.shopify.com/).

## Standards

* Checks should do one thing, and do it well.
* PR should explain what the feature does, and why the change exists.
* PR should include any carrier specific documentation explaining how it works.
* Code _must_ be tested.
* Be consistent. Write clean code that follows [Ruby community standards](https://github.com/bbatsov/ruby-style-guide).
* Code should be generic and reusable.

## How to contribute

1. Fork it ( https://github.com/Shopify/theme-check/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Running Tests

```
bundle install # Or `dev up` if you're from Shopify
bundle exec rake
```

## Checking a theme

```
bin/theme-check /path/to/your/theme
```

## Creating a new "Check"

Run `bundle exec rake "new_check[MyNewCheckName]"` to generate all the files required to create a new check.

Check the [Check API](/docs/api/check.md) for how to implement a check. Also take a look at other checks in [lib/theme_check/checks](/lib/theme_check/checks).

We done implementing your check, add it to `config/default.yml` to enable it:

```yaml
MyNewCheckName:
  enabled: true
  ignore: []
```

If the check is configurable, the `initialize` argument names and default values should also be duplicated inside `config/default.yml`. eg.:

```ruby
class MyCheckName < LiquidCheck
  def initialize(muffin_mode: true)
    @muffin_mode = muffin_mode
  end
  # ...
end
```

```yaml
MyNewCheckName:
  enabled: true
  ignore: []
  muffin_mode: true
```

## Debugging

A couple of things are turned on when the `THEME_CHECK_DEBUG` environment variable is set.

1. The check timeout is turned off. This means you can add `binding.pry` in tests and properly debug with `bundle exec rake tests:in_memory`
2. The `--profile` flag appears. You can now create Flamegraphs to inspect performance.

```
export THEME_CHECK_DEBUG=true

# The following will behave slightly differently
bin/theme-check ../dawn
bundle exec rake tests:in_memory

# The following becomes available
bin/theme-check --profile ../dawn

# The LanguageServer will log the JSONRPC calls to STDERR
bin/theme-check-language-server
```

### Profiling

`ruby-prof` and `ruby-prof-flamegraph` are both included as development dependencies.

#### Flamegraph

With the `--profile` flag, you can run theme-check on a theme and the `ruby-prof-flamegraph` printer will output profiling information in a format [Flamegraph](/brendangregg/FlameGraph) understands.


**Setup:** 

```bash
# clone the FlameGraph repo somewhere
git clone https://github.com/brendangregg/FlameGraph.git

# the flamegraph.pl perl script is in that repo
alias flamegraph=/path/to/FlameGraph/flamegraph.pl
```

**Profiling:**

```
# run theme-check with --profile
# pass the output to flamegraph
# dump the output into an svg file
bin/theme-check --profile ../dawn \
  | flamegraph --countname=ms --width=1750 \
  > /tmp/fg.svg

# open the svg file in Chrome to look at the flamegraph
chrome /tmp/fg.svg
```

What you'll see is an interactive version of the following image:

![flamegraph](docs/flamegraph.svg)
