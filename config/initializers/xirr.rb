Xirr.configure do |config|
  config.precision = 4
  config.raise_exception = true
  config.default_method = :newton_method
  config.iteration_limit = 10
  config.replace_for_nil = 0.0/0
end