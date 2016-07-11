require 'fpm/cookery/book'
require 'fpm/cookery/book_hook'
require 'fpm/cookery/path'
require 'fpm/cookery/recipe'

shared_context "temporary recipe" do |caller_filename = "recipe.rb", content = nil|
  let(:recipe_filename) { caller_filename }

  around do |example|
    %w{recipe book book_hook}.each { |m| require "fpm/cookery/#{m}" }

    FPM::Cookery::BaseRecipe.send(:include, FPM::Cookery::BookHook)

    Dir.mktmpdir do |tmpdir|
      Dir.chdir tmpdir do
        # Always open in order to ensure that the file exists, but only write
        # if we were actually given some content.
        begin
          File.open(recipe_filename, File::WRONLY | File::CREAT | File::EXCL) do |file|
            file.print content unless content.nil?
          end

          example.run
        rescue Errno::EEXIST => e
          skip e.message
        end
      end
    end
  end
end

# For setting up the proper framework to instantiate a recipe
shared_context "recipe class" do |caller_filename, caller_config_options = {}|
  def stub_dir(dir, path)
    value = path.nil? ? nil : FPM::Cookery::Path.new(path)
    allow(config).to receive(dir).and_return(value)
  end

  before(:all) do
    FPM::Cookery::BaseRecipe.send(:include, FPM::Cookery::BookHook)
  end

  before(:each) do
    FPM::Cookery::Book.instance.filename = filename
    FPM::Cookery::Book.instance.config = config
  end

  let(:recipe_klass) do
    Class.new(FPM::Cookery::Recipe)
  end

  let(:filename) do
    FPM::Cookery::Path.new(caller_filename).realpath
  end

  let(:config) do
    #double('Config', caller_config_options).as_null_object
    require 'fpm/cookery/config'
    FPM::Cookery::Config.new(caller_config_options)
  end

  let(:recipe) do
    recipe_klass.new
  end
end

# Instantiate a recipe and build a package
shared_context "temporary recipe class" do |caller_filename = "recipe.rb", caller_config_options = {}|
  include_context "recipe class", caller_filename, caller_config_options
  include_context "temporary recipe", caller_filename
end
