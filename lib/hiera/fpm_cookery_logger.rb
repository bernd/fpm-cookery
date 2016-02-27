require 'fpm/cookery/log/hiera'

# Note: this file exists because hiera runs +require "hiera/#{logger}_logger",
# where +logger+ refers to the name passed as the +:logger+ option to the
# +Hiera+ class' constructor.

# Note: This weird name is due to the relationship between how Hiera looks for the
# module to load ("require "#{logger}_logger") and how it infers the class
# name of its logger (Hiera.const_get("#{logger.capitalize}_logger") This
# class name is what would be constructed if the hiera object were created
# as follows: Hiera.new(:config => {:logger => "fpm_cookery"}).
Hiera::Fpm_cookery_logger = FPM::Cookery::Log::Hiera
