module RapidRack
  module DefaultReceiver
    def receive(env, claims)
      attrs = map_attributes(env, claims['https://aaf.edu.au/attributes'])
      store_id(env, subject(env, attrs).id)
      finish(env)
    end

    def map_attributes(_env, attrs)
      attrs
    end

    def store_id(env, id)
      env['rack.session']['subject_id'] = id
    end

    def finish(_env)
      redirect_to('/')
    end

    def redirect_to(url)
      [302, { 'Location' => url }, []]
    end

    def logout(env)
      env['rack.session'].destroy
      redirect_to('/')
    end
  end
end
