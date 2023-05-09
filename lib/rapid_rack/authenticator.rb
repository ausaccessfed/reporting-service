require 'json/jwt'
require 'rack/utils'

module RapidRack
  class Authenticator
    attr_reader :issuer, :audience, :secret, :error_handler
    private :issuer, :audience, :secret, :error_handler

    include WithClaims

    def initialize(opts)
      @url = opts[:url]
      @receiver = opts[:receiver].try(:constantize)
      raise('A receiver must be configured for rapid_rack') if @receiver.nil?

      @secret = opts[:secret]
      @issuer = opts[:issuer]
      @audience = opts[:audience]
      @error_handler = if opts[:error_handler].nil?
                         self
                       else
                         opts[:error_handler].constantize.new
                       end
    end

    def call(env)
      sym = DISPATCH[env['PATH_INFO']]
      return send(sym, env) if sym

      [404, {}, ["Not found: #{env['PATH_INFO']}"]]
    end

    def handle(_env, _exception)
      [
        400, { 'Content-Type' => 'text/plain' }, [
          'Sorry, your attempt to log in to this service was not successful. ',
          'Please contact the service owner for assistance, and include the ',
          'link you used to access this service.'
        ]
      ]
    end

    private

    DISPATCH = {
      '/login' => :initiate,
      '/jwt' => :callback,
      '/logout' => :terminate
    }
    private_constant :DISPATCH

    def initiate(env)
      return method_not_allowed unless method?(env, 'GET')

      [302, { 'Location' => @url }, []]
    end

    def callback(env)
      return method_not_allowed unless method?(env, 'POST')

      params = Rack::Utils.parse_query(env['rack.input'].read)
      with_claims(env, params['assertion']) do |claims|
        receiver.receive(env, claims)
      end
    end

    def terminate(env)
      return method_not_allowed unless method?(env, 'GET')

      receiver.logout(env)
    end

    def method?(env, method)
      env['REQUEST_METHOD'] == method
    end

    def method_not_allowed
      [405, {}, ['Method not allowed']]
    end

    def receiver
      @receiver.new
    end
  end
end
