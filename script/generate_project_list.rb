require 'octokit'
require 'repomen'
require 'yaml'

Repomen.config.work_dir = "tmp/"

class Project
  attr_reader :badges

  def initialize(attributes)
    @user_name = attributes[:user_name]
    @repo_name = attributes[:repo_name]
    @language = attributes[:language]
    @fork = attributes[:fork]
    @description = attributes[:description]
    @contributors = attributes[:contributors]
    @repo_url = attributes[:git_url]

    Repomen.retrieve(@repo_url) do |local_path|
      if readme_filename = find_readme(local_path)
        retrieve_badges File.read(readme_filename)
      end
    end
  end

  def fork?
    !!@fork
  end

  def to_h
    {
      'user_name' => @user_name,
      'repo_name' => @repo_name,
      'language' => @language,
      'fork' => @fork,
      'description' => @description,
      'contributors' => @contributors,
      'badges' => @badges,
      'repo_url' => @repo_url,
    }
  end

  private

  def retrieve_badges(content)
    slug = "/#{@user_name}/#{@repo_name}"
    gh_reference = "github.com#{slug}"
    images = content.scan(/(http\S+?\.(png|svg))/).map(&:first)
    @badges = images.select do |src|
      src.include?(slug) && !src.include?(gh_reference) && src !~ /raw\.github/
    end
  end

  # @return [String] filename
  def find_readme(local_path)
    Dir[File.join(local_path, '*.*')].detect do |f|
      File.basename(f) =~ /\Areadme\./i
    end
  end
end

class GitHubUser
  attr_reader :repos

  def self.repos(user_name)
    token = read_access_token(:github)
    client = Octokit::Client.new(:access_token => token)
    new(user_name, client).repos
  end

  def self.read_access_token(key)
    filename = File.join(__dir__, '..', '.access_tokens.yml')
    if File.exists?(filename)
      hash = YAML.load File.read(filename)
      hash[key.to_s]
    end
  end

  def initialize(user_name, client)
    @client = client
    @user_name = user_name
    @repos = []
    retrieve_repos
  end

  def repos
    @repos.map { |repo| attributes_for(repo) }
  end

  private

  def attributes_for(repo)
    attributes = repo.to_h
    attributes[:user_name] = @user_name
    attributes[:repo_name] = attributes[:name]
    attributes[:contributors] = contributors_for(attributes)
    attributes
  end

  def contributors_for(attributes)
    nwo = "#{attributes[:user_name]}/#{attributes[:repo_name]}"
    list = @client.contributors(nwo)
    if list.empty?
      []
    else
      list.map do |contributor|
        {
          'user_name' => contributor[:login],
          'avatar_url' => contributor[:avatar_url],
          'contributions' => contributor[:contributions],
        }
      end
    end
  end

  def retrieve_repos(page = 1)
    @repos.concat @client.repos(@user_name, :page => page)
    retrieve_repos(page + 1) if @client.last_response.rels[:next]
  end
end

repos = GitHubUser.repos('neopoly')

projects = repos.map do |repo|
  Project.new(repo)
end

puts projects.map(&:to_h).to_yaml
