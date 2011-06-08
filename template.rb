alias :old_ask :ask
def yes?(question, default_yes=false)
  (answer = old_ask("#{question} [#{default_yes ? "yes" : "no"}]")).blank? || ["yes","y"].include?(answer.downcase)
end
def ask(question, default)
  (answer = old_ask("#{question} [#{default}]")).blank? ? default : answer
end

remove_file 'Gemfile'
add_file 'Gemfile'

add_source 'http://rubygems.org'
append_to_file "Gemfile","\n"
gem "rails", Rails::VERSION::STRING
gem "rake"
gem "jquery-rails"
gem ask("What database gem should I use?", "mysql")

append_to_file 'Gemfile', <<EOF

group :development do
  gem 'capistrano'
  gem 'capistrano-ext'
  gem 'rvm'
  gem 'ruby-debug'
  #gem 'ruby-debug19' 
end

group :development, :test, :cucumber do
  gem 'capybara'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'cucumber-rails'
  gem 'database_cleaner'
  gem 'pickle'
  gem 'jasmine'
  gem 'launchy'
end
EOF

if yes?("Should I configure RVM?", true)
  inside '' do |path|
    add_file ".rvmrc", "rvm #{ruby_version = ask("What ruby version?", 'ree')}@#{application_name = path.split('/').last}"
    if !`rvm list`.match(ruby_version)
      if yes?("#{ruby_version} is not installed, would you like me to install it?",true)
      run "rvm install #{ruby_version}"
      else
        say "Unable to continue as the ruby version \"#{ruby_version}\" has not been installed, please continue manually"
        exit
      end
    end
    run "rvm use #{ruby_version}"
    run "rvm gemset create #{application_name}"
    run "rvm gemset use #{application_name}"
  end
end

run "bundle install"
run "bundle package"

generate "rspec:install"
generate "cucumber:install", "--capybara --rspec"
generate "jquery:install", (yes?("Include JQuery UI?", true) ? "--ui" : "")
generate "pickle", "--email --paths"
generate "jasmine:install"
capify!

git :init
git :add => '.'
git :commit => '-m "First commit"'

if( remote_git_repos = old_ask("What is the remote git repository? (leave blank for none)")).blank?
  if `git remote list`.blank?
    run "git remote set-url origin #{remote_git_repos}"
  else
    run "git remote add origin #{remote_git_repos}"
  end
  git :branch => "development"
  git :push => "origin development"
end







