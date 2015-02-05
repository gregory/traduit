require 'pry'
require 'traduit'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
  config.after(:each) do
    Traduit.flush
  end

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.mock_with :rspec do |c|
    c.syntax = :expect
  end
end

def build_translatable_class(options={}, *scopes, &block)
  Class.new { include Traduit.new(options, *scopes, &block) }
end
