# frozen_string_literal: true

module RapidRack
  class TestAuthenticator < Authenticator
    class << self
      attr_accessor :jwt
    end

    def call(env)
      return login if env['PATH_INFO'] == '/login'

      super
    end

    private

    def login
      jwt = TestAuthenticator.jwt || raise('No login JWT was set')
      out = [] << <<-LOGINPAGE
        <html><body>
          <form action="/auth/jwt" method="post">
            <input type="hidden" name="assertion" value="#{jwt}"/>
            <button type="submit">Login</button>
          </form>
        </body></html>
      LOGINPAGE
      [200, {}, out]
    end
  end
end
