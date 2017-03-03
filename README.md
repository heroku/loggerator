# loggerator

Provides a simple logging mechanism that will generate logs in a `key=value` style.

> This was adapted from the configuration implementation in [Pliny](https://github.com/interagent/pliny).

Loggerator offers the following functionality:

* Simple `log` helpers
* RequestID generation, chaining
* Rails Integration
* Simple `m` helper for l2met metrics

## Installation

Add this to your application's Gemfile:
```ruby
gem 'loggerator'
```

Then, execute:
```bash
$ bundle
```

Or install it yourself:
```bash
$ gem install loggerator
```

### Rails Integration

Loggerator offers integration points for the Rails framework.
* It adds log helpers to ActionView, ActiveRecord, ActionController, and ActionMailer
* It will setup your default log context in an initalizer
* It will remove existing log subscribers on controller actions and replace it with a custom log subscriber

#### Log Helpers

Amend your Gemfile to include the Rails integration:
```ruby
gem "loggerator", require: "loggerator/rails"
```

Then, execute:
```bash
$ bundle
```

This adds `log`, `log_error`, `log_context` to the class and instance methods for ActionView, ActiveRecord, ActionController, and ActionMailer.

#### Initializer

Generate an initializer file:
```bash
rails g loggerator:log
```

This will use your rails project name by default. If you want use a different name for your default log context you can specify it at generation:

```bash
rails g loggerator:log -a myapp
```

Or you can set it manually or through configuration in the generated initialization file `config/initializers/log.rb`. For example:

```ruby
Loggerator.config.default_context = { app: Config.app_name }
```

#### Custom Log Subscriber

By default, upon including `loggerator/rails`, Loggerator will remove the default log subscribers that listen on controller actions, including redirection. The new log output should look something like this.

```
app=example_app method=GET path=/ format=*/* controller=main action=index status=200 duration=7.920 view=0.500 db=0.280
```

You can disable this, using the default logger by adding or updating `config/initializers/log.rb`, to contain the following.

```
Loggerator.config.rails_default_subscribers = true
```

### Metrics Integration

When including metrics, these will be added to the log items available:
* It adds metrics helpers alongside the log helpers
* It will setup your default log context in an initalizer

#### Metrics Helper

Currently, the only metrics integration is written for [l2met](https://github.com/ryandotsmith/l2met).

Amend your Gemfile to include the l2met integration:

```ruby
gem "loggerator", require: ["loggerator/rails", "loggerator/metrics"]
```

Or require it yourself:
```bash
require 'loggerator/metrics'
```

This adds the `m` helper to the class and instance methods for ActionView, ActiveRecord, ActionController, and ActionMailer.

#### Initializer

If you have setup Loggerator to require Metrics before generating an initializer, Metrics configuration will be included.

Generate an initializer file:
```bash
rails g loggerator:log
```

This will use your rails name by default, if you want use a different name for your default log context you can specify it at generation:

```bash
rails g loggerator:log -a myapp
```

Or you can set it manually or through configuration in the generated initialization file `config/initializers/log.rb`. For example:

```ruby
Loggerator.config.metrics_app_name = Config.app_name
```

### Namespaces

To use Namespaces, you need to make sure to amend your Gemfile:
```ruby
gem "loggerator", require: 'loggerator/namespace'
```

Or require it yourself:
```bash
require 'loggerator/namespace'
```

This allows you to add namespaces to logs for modules/classes that include
`Loggerator::Namespace`.

## Usage

Logs are sent to `stdout` and `stderr` as a stream to follow the [12factor](https://12factor.net/logs) methodology.  This can be altered through configuration.

Assume that the following examples have the following configuration:

```ruby
Loggerator.config do |c|
  c.default_context = { app: "myapp" },
  c.metrics_app_name = "myapp"
end
```

### Log Helpers

#### `log`

Use `log` to log any key-value pairs, they can be any value.

Logs are sent to `stdout` by default

```ruby
log test1: "first", test2: 123  #=> app=myapp test1=first test2=123
```

Use blocks to emit timing information, assuming `test_method` does the following:
```
def test_method
  log(sleep: 0.4)
  sleep(0.4)
end
```

Then you can see actual timing with:

```ruby
log timing: "test_method" do
  test_method
  log success: true
end
#=> app=myapp timing=test_method at=start
#=> app=myapp sleep: 0.400
#=> app=myapp success
#=> app=myapp timing=test_method at=finish elapsed=0.401
```

#### `log_context`

You can use `log_context` to add values to all encompassed `log` commands

```ruby
log_context group: "test_method" do
  log try: 1
  test_method
  log success: true
end
#=> app=myapp group=test_method try=1
#=> app=myapp group=test_method sleep: 0.400
#=> app=myapp group=test_method success
```

#### `log_error`

Log exception information using `log_error`.  It will log the class, message, and backtrace.  Every frame of the backtrace will be logged on its own line and is reverse-ordered so that the most relevant stack frames are last. All the logs will be tied together by a common `exception_id`.

Errors logs are sent to `stderr` by default.

```ruby
begin
  raise "this is an error"
rescue => ex
  log_error(ex)
end

emit_error
#=> app=myapp exception_id=70113140892880 backtrace="(pry):64:in `<main>'"
#=> app=myapp exception_id=70113140892880 backtrace="(pry):53:in `emit_error'"
#=> app=myapp exception_id=70113140892880 exception class=RuntimeError message="this is an error"
```

You can add additional key-value pairs to `log_error`

```ruby
begin
    raise "this is an error"
rescue => ex
    log_error(ex, try: 2)
end
#=> app=myapp exception_id=70113140892880 exception class=RuntimeError message="this is an error" try=2
```

### Formatting Rules

#### Strings

Loggerator will handle strings sanely by wrapping in quotes when needed:

```ruby
log no_spaces: "first", spaces: "second test"
#=> app=myapp no_spaces=first spaces="second test"
```

And handles embedded quotes:
```ruby
log double: %q[test with a "double-quote"], single: %q[test with a 'single-quote']
#=> app=myapp double='test with a "double-quote"' single="test with a 'single-quote'"

log embedded_quotes: %q[test with a "double-quote with a 'single-quote' inside"]
#=> app=myapp embedded_quotes="test with a \"double-quote with a 'single-quote' inside\""
```

#### Numbers

Floats will be formatted to three digits of precision, all other numbers will be shown as-is.

```ruby
log pi: 3.14159, integer: 123456789  #=> app=myapp pi=3.142 integer=123456789"
```

#### Booleans

True values will only show the key, false values are shown as is.

```ruby
log on: true, off: false  #=> app=myapp on off=false"
```

#### Nil

Nil values will be removed

```ruby
log removed: nil  #=> app=myapp"
```

#### Time

Time will be formatted using [iso8601](http://ruby-doc.org/stdlib-2.3.1/libdoc/date/rdoc/Date.html#method-c-iso8601) format

```ruby
log time: Time.now  #=> app=myapp  time=2016-10-10T16:13:29-07:00"
```

#### Procs

Procs will be executed, their results will follow the formatting rules above.

```ruby
log summation: -> { 3 + 2 + 1 }  #=> app=myapp summation=6
```

#### Default

Everything else won't be transformed by formatting rules.  Instead, they'll be logged by running `to_s` on the object.

```ruby
log class: Loggerator  #=> app=myapp class=Loggerator
```

### Namespace

Sometimes you want to log the class/module name for every log message.  Loggerator can log these as "namespaces".  An example we use is for a set of similar subclasses without needing to distinguish between them.

You will need to `include Loggerator::Namespace` on the class/module you want to add a namespace.  Subclasses will inherit namespace logging.

For example, if we have a set of Mediators:
```ruby
class Mediator
  def self.run
    new.call
  end
end

class CreateMediator < Mediator
  def call
    log call: true
    # do a thing
  end
end

class UpdateMediator < Mediator
  def call
    log call: true
    # do a thing
  end
end
```

When you run each of these mediators, it will log a new `ns` key-value pair:

```ruby
CreateMediator.run  #=> app=myapp ns=CreateMediator call
UpdateMediator.run  #=> app=myapp ns=UpdateMediator call
```

### Metrics

Metrics uses the [l2met](https://github.com/ryandotsmith/l2met/wiki/Usage) convention to log `count`, `sample`, `measure`, and `unique` using the `m` helper.  It uses the name set in configuration.  If it is not set, it will use "loggerator".

These metrics are sent to `stdout` by default.

```ruby
m.count(:clicks)                          #=> app=myapp count#myapp.clicks=1
m.count(:clicks, 2)                       #=> app=myapp count#myapp.clicks=2
m.sample("database.size", "40.9MB")       #=> app=myapp sample#myapp.database.size=40.9MB
m.measure("database.query", "200")        #=> app=myapp measure#myapp.database.query=200s
m.measure("database.query", "200", "ms")  #=> app=myapp measure#myapp.database.query=200ms
m.unique(users, 244)                      #=> app=myapp unique#myapp.users=244
```

### Instance & Singleton methods

When you include `Loggerator` modules including `Loggerator::Metrics` and `Loggerator::Namespace`, the methods will be available as both instance methods and singleton methods.

```ruby
class Foo
  include Loggerator::Namespace
  log defining: "class"

  def test
    log executing: "test"
  end
end
#=> app=myapp ns=Foo defining=class

Foo.new.test
#=> app=myapp ns=Foo executing=test
```

## Configuration

> NOTE: Version `0.1.0` contains breaking configuration changes. Please review the following section and adjust your configuration accordingly.

There are a few configuration options that can be setup in your initializer.

```ruby
Loggerator.config do |c|

  # Set loggerator's default context. These are the key/value pairs
  # defining your application, which are prepended to every log line.
  c.default_context = { app: "myapp", env: Rails.env }

  # Set loggerator's metrics name. This is the name to be included as
  # part of the metric key when emitting metrics.
  c.metrics_app_name = Config.app_name

  # Requiring 'loggerator/rails' automatically overrides Rails' log subscribers
  # for controller handling with it's own log subscriber.
  #
  # In case you may need to disable this functionality, the following is
  # a simple method for turning this off, causing the default logging to be
  # modified.
  c.rails_default_subscribers = true

end
```

You can also provide different streams to use instead of `stdin` and `stderr`

Here's a contrived example:
```ruby
$log = StringIO.new
Loggerator.config.stdout = $log
Loggerator.config.stderr = $log
```

## Testing

Logs are turned off in your specs, when you add the following near the top of your `spec_helper.rb` or `test_helper.rb`:

```ruby
require 'loggerator/test'
```

If you'd like to see them when running your tests, you can force them on with:

```bash
TEST_LOGS=1 rake
```

You can also turn the logs off and on programmtically in your tests:

```ruby
log test1: "turned off"
Loggerator.turn(:on)
log test2: "turned on"
Loggerator.turn(:off)
log test3: "turned on"
```

In the prior example, only `test2` would be printed to the log.

To see if the logs are turned on off

```ruby
Loggerator.turn(:on)
Loggerator.log?       #=> true

Loggerator.turn(:off)
Loggerator.log?       #=> false
```

