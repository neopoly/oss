
task :default => :help

desc "List all tasks"
task :help do
  system "rake", "-T"
end

desc "Generate projects page"
task :projects => [:"projects:html", :"projects:md"]

namespace :projects do

  def generate(yaml, template, output)
    require_relative "script/page_builder"

    File.open(output, "wb") do |fh|
      content = PageBuilder.render(yaml, template)
      fh.write content
    end
  end

  desc "Generate projects page in HTML"
  task :html do
    generate "projects.yml", "templates/index.html.erb", "index.html"
  end

  desc "Generate projects page in Markdown"
  task :md do
    generate "projects.yml", "templates/index.md.erb", "index.md"
  end

  desc "Genearte project list"
  task :list do
    require "bundler"
    Bundler.setup
    require_relative "script/generate_project_list.rb"

    repos = GitHubUser.repos('neopoly')

    projects = repos.map do |repo|
      Project.new(repo)
    end

    File.open("projects.yml", "wb") do |fh|
      yaml = projects.map(&:to_h).to_yaml
      fh.write yaml
    end
  end

end
