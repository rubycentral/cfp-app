Rake::Task["assets:precompile"].enhance ["yarn:install"]

# Heroku ships everything left in the build directory, and node_modules is only
# needed while esbuild and PostCSS run. STACK (e.g. "heroku-26") is set during
# Heroku builds and nowhere else, so local and CI precompiles keep node_modules.
Rake::Task["assets:precompile"].enhance do
  FileUtils.rm_rf("node_modules") if ENV["STACK"].to_s.start_with?("heroku-")
end
