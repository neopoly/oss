require 'service/github/user'

module Service
  module GitHub
    class Repo < User
      def initialize(slug, client)
        @client = client
        @user_name = slug.split('/').first
        @repos = [client.repo(slug)]
      end

      def repo
        repos.first
      end
    end
  end
end
