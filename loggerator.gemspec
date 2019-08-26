Gem::Specification.new do |s|
  s.name        = "loggerator"
  s.version     = "0.1.3"
  s.summary     = "loggerator: A Log Helper"
  s.description = "Simple web application extension for logging, following the 12factor pattern."
  s.authors     = ["Joshua Mervine", "Reid MacDonald"]
  s.email       = ["joshua@mervine.net", "reidmix@gmail.com"]
  s.files       = `git ls-files -- lib/*`.split("\n")
  s.test_files  = `git ls-files -- test/*`.split("\n")
  s.homepage    = "https://github.com/heroku/loggerator"
  s.license     = "MIT"
end
