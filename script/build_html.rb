
require 'erb'
require 'ostruct'
require 'yaml'

class HtmlBuilder
  DEFAULT_PROJECT_YAML = 'projects.yml'
  DEFAULT_PROJECT_ERB  = 'templates/index.html.erb'
  DEFAULT_PROJECT_HTML = 'projects.html'

  attr_reader :projects, :render

  def self.render(*args)
    new(*args).render
  end

  def initialize(yaml_file)
    filename = yaml_file || DEFAULT_PROJECT_YAML
    @projects = load_yaml(filename).map { |hash| OpenStruct.new(hash) }
    @projects = @projects.reject(&:fork)

    @languages = @projects.map(&:language).uniq.compact.sort
  end

  def render
    erb = File.read(DEFAULT_PROJECT_ERB)
    template = ERB.new(erb)
    template.result(binding)
  end

  private

  def load_yaml(filename)
    YAML.load(File.read(filename))
  end
end

puts HtmlBuilder.render(ARGV.first)
