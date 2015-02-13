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

      def read_access_token(key)
        filename = File.join(__dir__, '..', '..', '.access_tokens.yml')
        if File.exists?(filename)
          hash = YAML.load File.read(filename)
          hash[key.to_s]
        end
      end
    end

    class User
      attr_reader :repos

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
  end
end
