
class Project
  attr_reader :badges
  attr_reader :repo_url

  def initialize(attributes, load_badges = true)
    update(attributes, load_badges)
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

  def update(hash, load_badges = true)
    attributes = Hash[hash.map{ |k, v| [k.to_sym, v] }]

    @user_name = attributes[:user_name]
    @repo_name = attributes[:repo_name]
    @language = attributes[:language]
    @fork = attributes[:fork]
    @description = attributes[:description]
    @contributors = attributes[:contributors]
    @repo_url = attributes[:repo_url] || attributes[:git_url]
    @badges = attributes[:badges]

    if load_badges
      Repomen.retrieve(@repo_url) do |local_path|
        if readme_filename = find_readme(local_path)
          retrieve_badges File.read(readme_filename)
        end
      end
    end
  end

  private

  def retrieve_badges(content)
    slug = "/#{@user_name}/#{@repo_name}"
    gem_reference = "/gem/v/#{@repo_name}"
    gh_reference = "github.com#{slug}"
    images = content.scan(/(http\S+?\.(png|svg))/).map(&:first)
    @badges = images.select do |src|
      (src.include?(slug) || src.include?(gem_reference)) &&
        !src.include?(gh_reference) && src !~ /raw\.github/
    end
  end

  # @return [String] filename
  def find_readme(local_path)
    Dir[File.join(local_path, '*.*')].detect do |f|
      File.basename(f) =~ /\Areadme\./i
    end
  end
end
