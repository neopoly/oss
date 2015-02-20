require 'yaml'

class ProjectConfig
  FILENAME = "config.yml"

  def initialize(filename = FILENAME)
    @data = YAML.load(File.read(filename))
  end

  def included_user_names
    included_users.map { |slug| slug.gsub('/*', '') }
  end

  def included_repositories
    included - included_users
  end

  def excluded_repositories
    excluded
  end

  private

  def included_users
    included.select { |slug| slug =~ /\/\*$/ }
  end

  def excluded
    projects['exclude'] || []
  end

  def included
    projects['include'] || []
  end

  def projects
    @data['projects'] || {}
  end
end
