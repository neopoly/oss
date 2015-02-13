module Service
  module GitHub
    class User
      def initialize(user_name, client)
        @client = client
        @user_name = user_name
        @repos = []
        retrieve_repos
      end

      def repos
        @repos.map { |repo| attributes_for(repo) }
      end

      protected

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
