require 'pleaserun/namespace'
require 'pleaserun/detector'

module FPM
  module Cookery
    class StartupScript
      attr_accessor :program, :name, :args, :user, :group, :description,
                    :chdir, :umask, :prestart

      def initialize
        @platform, @target_version = PleaseRun::Detector.detect

        require "pleaserun/platform/#{@platform}"
        const = PleaseRun::Platform.constants.find { |c| c.to_s.downcase == @platform.downcase }

        @platform_class = PleaseRun::Platform.const_get(const)
        @runner = @platform_class.new(@target_version)
      end

      def write_to(root)
        ensure_attributes!

        @runner.files.each do |path, content, perms|
          fullpath = root + path.gsub(%r(^/+), '')

          FileUtils.mkdir_p(File.dirname(fullpath))
          File.open(fullpath, 'w') {|f| f.write(content) }
          File.chmod(perms, fullpath) if perms
        end

        # TODO Check how to install action scripts. pre/post script?
        #PleaseRun::Installer.write_actions(@runner, ...)
      end

      private

      def ensure_attributes!
        @runner.program = program
        @runner.name = name || File.basename(program)
        @runner.args = args.split(/\s+/) if args
        @runner.user = user if user
        @runner.group = group if group
        @runner.description = description if description
        @runner.chdir = chdir if chdir
        @runner.umask = umask if umask
        @runner.prestart = prestart if prestart
      end
    end
  end
end
