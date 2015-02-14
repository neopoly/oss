require 'yaml'
require 'octokit'
require 'base64'

require 'service/github/user'
require 'service/github/repo'

module Service
  module GitHub
    class << self
      def client
        @client ||= begin
                      token = read_access_token(:github)
                      Octokit::Client.new(:access_token => token)
                    end
      end

      def repos(user_name)
        User.new(user_name, client).repos.tap do |repos|
          repos.each do |repo|
            repo[:readme] = readme(repo[:full_name])
          end
        end
      end

      def repo(slug)
        repo = Repo.new(slug, client).repo
        repo[:readme] = readme(slug)
        repo
      end

      private

      def readme(slug)
        path = "#{Octokit::Repository.path(slug)}/readme"
        encoded = client.get(path)[:content]
        Base64.decode64(encoded)
      rescue Octokit::NotFound
        nil
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
