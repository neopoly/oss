desc "Release current state of Neopoly OSS"
task :release => [:"release:github"]

namespace :release do
  def shell(task)
    puts "Running: #{task}"
    system task
  end

  desc "Release to GitHub pages"
  task :github do
    shell "git fetch"
    shell "git checkout gh-pages"
    shell "git pull"
    shell "git merge master"
    shell "git push"
    shell "git checkout master"
  end
end