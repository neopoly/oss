$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'yaml'
require 'oss'

desc "Generate projects page"
task :projects => [:"projects:html", :"projects:md"]

namespace :projects do

  ROOT_DIR = ".."

  def generate(yaml, template, output)
    require_relative "#{ROOT_DIR}/script/page_builder"

    File.open(output, "wb") do |fh|
      content = PageBuilder.render(yaml, template)
      fh.write content
    end
  end

  def list(config, output)
    puts "Fetching project list. Be patient..."

    repos = []
    config.included_user_names.each do |user|
      repos.concat Service::GitHub.repos(user)
    end
    config.included_repositories.each do |slug|
      repos << Service::GitHub.repo(slug).to_h
    end

    repos = repos.reject do |repo|
      slug = "#{repo[:user_name]}/#{repo[:repo_name]}"
      config.excluded_repositories.include?(slug)
    end

    projects = repos.map do |repo|
      Project.new(repo)
    end

    File.open(output, "wb") do |fh|
      yaml = projects.map(&:to_h).to_yaml
      fh.write yaml
    end
  end

  def update(slug, filename)
    projects = File.exists?(filename) ? YAML.load(File.read(filename)) : []
    projects = projects.map do |attributes|
      Project.new(attributes, false)
    end

    attributes = Service::GitHub.repo(slug).to_h

    projects.each do |project|
      if project.repo_url.include?(slug)
        project.update attributes
      end
    end

    File.open(filename, "wb") do |fh|
      yaml = projects.map(&:to_h).to_yaml
      fh.write yaml
    end
  end

  PROJECTS_YAML = "projects.yml"

  desc "Generate projects page in HTML"
  task :html do
    generate PROJECTS_YAML, "templates/index.html.erb", "index.html"
  end

  desc "Generate projects page in Markdown"
  task :md do
    generate PROJECTS_YAML, "templates/index.md.erb", "index.md"
  end

  desc "Genearte project list"
  task :list do
    list ProjectConfig.new, PROJECTS_YAML
  end

  desc "Update project set in PROJECT"
  task :update do
    slug = ENV['PROJECT'] || raise("Set PROJECT=username/repo")
    update slug, PROJECTS_YAML
  end

end
