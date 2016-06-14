require 'spec_helper'

require 'fpm/cookery/book'

describe "Book" do
  let(:book) { FPM::Cookery::Book.instance }
  let(:config) do
    attrs = {
      :debug        => false,
      :hiera_config => {
        # Silence logging
        :logger => :noop
      }
    }

    double('Config', attrs).as_null_object
  end

  describe ".instance" do
    describe ".load_recipe" do
      context "given an existing file" do
        include_context "temporary recipe", <<-RECIPE
          class FakeRecipe < FPM::Cookery::Recipe
            print 'Hello, world!'
          end
        RECIPE

        it "loads the file" do
          expect { book.load_recipe('recipe.rb', config) { } }.to output('Hello, world!').to_stdout
        end
      end
    end
  end
end
