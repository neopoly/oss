$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'oss'

if $0 == __FILE__
  repos = Service::GitHub.repos('neopoly')

  projects = repos.map do |repo|
    Project.new(repo)
  end

  puts projects.map(&:to_h).to_yaml
end
