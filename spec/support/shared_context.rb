require 'fpm/cookery/path'

shared_context "temporary recipe" do |content, filename = "recipe.rb"|
  let(:recipe) { filename }

  around do |example|
    %w{recipe book book_hook}.each { |m| require "fpm/cookery/#{m}" }

    FPM::Cookery::BaseRecipe.send(:include, FPM::Cookery::BookHook)

    Dir.mktmpdir do |tmpdir|
      Dir.chdir tmpdir do
        File.open(filename, 'w') do |file|
          file.print content
          file.close
          example.run
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

  let(:klass) do
    Class.new(FPM::Cookery::Recipe)
  end

  let(:filename) do
    caller_filename
  end

  let(:config) do
    double('Config', caller_config_options).as_null_object
  end

  let(:recipe) do
    klass.new
  end
end
