# JsonLogger

Forked from Huyegger gem (https://github.com/mainameiz/huyegger).

This is a Ruby JSON Logger compatible with Rails, Sinatra, Rack and Sidekiq.

## Installation

```ruby
gem 'json_logger', git: 'https://github.com/apptweak/json_logger'
```

## Basic usage

```ruby

file_logger = Logger.new("/log/your_progname.log") # You can also use 'syslog/logger' instead of default ruby logger
logger = JsonLogger::Logger.new(file_logger)

require 'oj' # OR require 'json' for using default json encoder implementation (Object#to_json)
# Configure json encoder 
JsonLogger.json_encoder = proc { |obj| Oj.dump(obj, mode: :compat) }

# Write simple messages : 
logger.info("hello world !")
# => { "level":"INFO", "message":"hello world !", "timestamp":"2018-12-20T11:09:09+00:00" }

# Write messages with additional fields : 
logger.info(from: "Alice", to: "Bob", message: "hello world !")
# => { "level":"INFO", "message":"hello world !", "from":"Alice", "to":"Bob", "timestamp":"2018-12-20T11:15:02+00:00"}

```
## Context

```ruby

# Define a context for all logs
logger.context(user_id: 3)
logger.info("Creating order 1")
# => { "level":"INFO", "user_id":3, "message":"Creating order 1", "timestamp":"2018-12-20T11:26:16+00:00" }
logger.info("Creating order 2")
# => { "level":"INFO", "user_id":3, "message":"Creating order 2", "timestamp":"2018-12-20T11:30:45+00:00" }

# Add fields to current context
logger.add_fields_to_context(user_name: "James")
logger.info("Creating order 3")
# => { "level":"INFO", "user_id":3, "user_name":"James", "message":"Creating order 3", "timestamp":"2018-12-20T11:33:53+00:00" }

# Clear context
logger.clear_context!

```
## Properties to display

1. caller_method : Name of the method you are logging from
2. caller_params : Name and values of the parameters of the method you are logging from
3. caller_location : Location where the method you are logging from is used
4. backtrace : Backtrace starting at the method you are logging from

Note: by default all properties are disabled.

```ruby

# Indicate which properties you want to display and then log a message
logger.display(caller_method: true, caller_params: true)
      .info("Creating new order")
# => { "level":"INFO", "message":"Creating new order", "timestamp":"2018-12-20T12:50:22+00:00", 
#      "caller_method":"create_order", "caller_params":[{"name":"order_id","value":"43"}, {"name":"day","value":"10"},
#                                                      {"name":"month","value":"12"}, {"name":"year","value":"2018"}]}
```
## Silence logger

```ruby

# Silence the logger for the block duration
logger.silence do
  # Code
end
```

## Integration with Rails

```ruby

# Inside config/environments/production.rb or development.rb depending on the environment 
# for which you want to use the json_logger
require "json_logger/railtie"
require "oj" # Not mandatory => require 'json' for using the default json encoder

file_logger = Logger.new("#{Rails.root}/log/#{Rails.env}.log")
config.logger = JsonLogger::Logger.new(file_logger, "Rails")
JsonLogger.json_encoder = proc { |obj| Oj.dump(obj, mode: :compat) } # Not mandatory

------------------

# Inside app/controller/application_controller.rb
class ApplicationController < ActionController::Base
  before_action :set_context

  ...

  def set_context
    Rails.logger.context(
      "http.host" => request.host,
      "http.method" => request.request_method,
      "http.path" => request.path,
      "http.addr" => request.remote_ip
    ) if Rails.logger.respond_to?(:context)
  end
end
```

## Integration with Sinatra

```ruby

# Instanciate and set logger inside config.ru OR directly inside app.rb
file_logger = Logger.new(STDOUT)
json_logger = JsonLogger::Logger.new(file_logger, "Sinatra")

# Configure json encoder
JsonLogger.json_encoder = proc { |obj| Oj.dump(obj, mode: :compat) } # Not mandatory

MyApp.set :logger, json_logger

run MyApp

------------------

# Inside app.rb
# For modular application
require 'sinatra/custom_logger'

class MyApp < Sinatra::Base
  helpers Sinatra::CustomLogger
  ...

  # Instanciate and set logger if not already done in config.ru

# For classic application
require 'sinatra/custom_logger'
  ...

  # Instanciate and set logger if not already done in config.ru

```

## Integration with Rack

```ruby
# Inside config.ru

require "json_logger/middlewares/rack_logger"
require "oj"

file_logger = Logger.new(STDOUT)
json_logger = JsonLogger::Logger.new(file_logger)

# Configure json encoder
JsonLogger.json_encoder = proc { |obj| Oj.dump(obj, mode: :compat) } # Not mandatory

# Declare Rack Logger Middelware
use JsonLogger::Middlewares::RackLogger, json_logger

``` 

## Integration with Sidekiq

```ruby

# Inside config/initializers/sidekiq.rb

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add JsonLogger::Middlewares::Sidekiq
  end
end
```


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/apptweak/json_logger.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
