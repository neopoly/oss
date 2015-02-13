require 'service/github/user'
require 'service/github/repo'

module Service
  module GitHub
    class << self
      def client
        token = read_access_token(:github)
        Octokit::Client.new(:access_token => token)
      end

      def repos(user_name)
        User.new(user_name, client).repos
      end

      def repo(slug)
        Repo.new(slug, client).repo
      end

      def read_access_token(key)
        filename = File.join(__dir__, '..', '..', '.access_tokens.yml')
        if File.exists?(filename)
          hash = YAML.load File.read(filename)
          hash[key.to_s]
        end
      end
    end
  end
end
