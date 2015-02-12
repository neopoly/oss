
require 'erb'
require 'ostruct'
require 'yaml'

class HtmlBuilder
  DEFAULT_PROJECT_YAML = 'projects.yml'
  DEFAULT_PROJECT_ERB  = 'templates/index.html.erb'

  attr_reader :projects, :render

  def self.render(*args)
    new(*args).render
  end

  def initialize(yaml_file=nil, template=nil)
    yaml_file ||= DEFAULT_PROJECT_YAML
    @template = template || DEFAULT_PROJECT_ERB
    @projects = load_yaml(yaml_file).map { |hash| OpenStruct.new(hash) }
    @projects = @projects.reject(&:fork).sort_by(&:repo_name)

    @languages = @projects.map(&:language).uniq.compact.sort
  end

  def render
    erb = File.read(@template)
    template = ERB.new(erb)
    template.result(binding)
  end

  private

  def load_yaml(filename)
    YAML.load(File.read(filename))
  end
end

if $0 == __FILE__
  puts HtmlBuilder.render(*ARGV)
end
