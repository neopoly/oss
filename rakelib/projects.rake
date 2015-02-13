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

  def list(user, output)
    require_relative "#{ROOT_DIR}/script/generate_project_list.rb"

    repos = GitHubUser.repos(user)

    projects = repos.map do |repo|
      Project.new(repo)
    end

    File.open(output, "wb") do |fh|
      yaml = projects.map(&:to_h).to_yaml
      fh.write yaml
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
    list "neopoly", "projects.yml"
  end

end
