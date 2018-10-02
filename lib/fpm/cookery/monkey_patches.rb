module FPM
  module Cookery
    class MonkeyPatches
      require 'openssl'
      # On newer systems running openssl 1.1 or greater, DEFAULT_PARAMS[:ciphers]
      # isn't set, so we need this conditional block otherwise puppet will abort
      # with an `undefined method` error
      class OpenSSL::SSL::SSLContext
        if DEFAULT_PARAMS[:ciphers]
          DEFAULT_PARAMS[:ciphers] << ':!SSLv2'
        end
      end
    end
  end
end
