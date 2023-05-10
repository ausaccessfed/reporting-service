# frozen_string_literal: true

module Authentication
  class SubjectReceiver
    include RapidRack::RedisRegistry

    def receive(env, claims)
      attrs = map_attributes(env, claims['https://aaf.edu.au/attributes'])
      store_id(env, subject(env, attrs).id)
      finish(env)
    end

    def map_attributes(_env, attrs)
      {
        targeted_id: attrs['edupersontargetedid'],
        shared_token: attrs['auedupersonsharedtoken'],
        name: attrs['displayname'],
        mail: attrs['mail']
      }
    end

    def subject(_env, attrs)
      subject = subject_scope(attrs).find_or_initialize_by({})
      check_subject(subject, attrs) if subject.persisted?

      subject.update!(attrs.merge(complete: true))
      update_roles(subject)
      subject
    end

    def finish(env)
      url = env['rack.session']['return_url'].to_s
      env['rack.session'].delete('return_url')

      return redirect_to(url) if url.present?

      redirect_to('/')
    end

    def update_roles(subject)
      admins = Rails.application.config.reporting_service.admins
      subject.entitlements = admins.fetch(subject.shared_token.to_sym, [])
    end

    def store_id(env, id)
      env['rack.session']['subject_id'] = id
    end

    def redirect_to(url)
      [302, { 'Location' => url }, []]
    end

    def logout(env)
      env['rack.session'] = {}
      redirect_to('/')
    end

    private

    def subject_scope(attrs)
      t = Subject.arel_table
      Subject.where(t[:targeted_id].eq(attrs[:targeted_id])
        .or(t[:shared_token].eq(attrs[:shared_token])))
    end

    def check_subject(subject, attrs)
      require_subject_match(subject, attrs, :targeted_id)
      require_subject_match(subject, attrs, :shared_token)
    end

    def require_subject_match(subject, attrs, key)
      incoming = attrs[key]
      existing = subject.send(key)
      return if existing == incoming

      raise("Incoming #{key} `#{incoming}` did not match" \
            " existing `#{existing}`")
    end
  end
end
