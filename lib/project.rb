
class Project
  attr_reader :badges

  def initialize(attributes)
    update(attributes)
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

  def update(attributes)
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
