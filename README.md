# Traduit

The goal of traduit is to provide a clean way to bring translation in any ruby class.

## Installation

```ruby
gem 'traduit'
```

### Config

You will need to set 1 or more backends in an initializer

```ruby
Traduit.backend = I18n
Traduit.backend[:db] = I18n, method: :translate
Traduit.backends # => { default: I18n, db: Translation}
```

## Usage

```ruby
class User
  include Traduit.new(namespace: 'users', [:subnamespace])

  def address
    t(:address, street: street, city: city) # => will look at users.subnamespace.address
  end
end

class BaseWorker
  include Traduit.new(namespace: 'workers') do |worker|
    worker.class.name.downcase.split('::')
  end
end

class Foo::BarWorker < BaseWorker
  def perform
    t(:failed) # => will look at workers.foo.barworker.failed
  end
end

class Foo < BaseWorker
  traduit namespace: :awesome, backend: :db

  def perform
    t(:failed) # => will look at workers.foo.awesome.failed
  end
end

class ApiBaseController < ApplicationController
  include Traduit.new(backend: :db, namespace: 'controllers', [:api]) do |controller|
    controller.params.values_at(:controller, :action)
  end
end

class UsersController < ApiBaseController
  def new
    flash[:error] = t(:failed, error: error) #=> will look at controllers.api.users.new.failed
  end
end
```


## Contributing

1. Fork it ( https://github.com/[my-github-username]/traduit/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
