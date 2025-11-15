require "sequel"
require "sequel/extensions/migration"
require_relative "./app/db/sequel"

namespace :db do
  desc "Run migrations"
  task :migrate do
    Sequel::Migrator.run(DB, "app/db/migrations")
    puts "Migrations executed."
  end
end