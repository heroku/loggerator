require 'fileutils'
VERSIONS = %w[ 2.1 2.2 2.3 latest ].freeze

def dcrm_test(version: "latest")
  puts "\n---\nRunning tests using Docker on Ruby (#{version})"
  FileUtils.rm_f("Gemfile.lock", verbose: true)
  FileUtils.rm_f(".bundle/config", verbose: true)

  test = version == "latest" ? "test" \
    : "test_#{version.gsub(".", "_")}"

  sh("docker-compose run --rm #{test}")
end

begin
  require "rake/testtask"

  Rake::TestTask.new do |t|
    t.pattern = "test/**/*_test.rb"
  end

rescue LoadError
  desc "Run tests using Docker on Ruby (latest)"
  task :test do
    dcrm_test
  end
end

task default: :test

desc "Run tests on all support Ruby versions using Docker"
task :regression do |_, args|
  versions = args.to_a & VERSIONS

  if versions.empty?
    versions = VERSIONS
    dcrm_test
  end

  versions.each do |version|
    dcrm_test(version: version)
  end
end

VERSIONS.each do |version|
  desc "Run tests using Docker on Ruby (#{version})"
  task "test:#{version}" do
    dcrm_test(version: version)
  end
end
