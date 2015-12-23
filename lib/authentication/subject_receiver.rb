module Authentication
  class SubjectReceiver
    include RapidRack::DefaultReceiver
    include RapidRack::RedisRegistry
    include IdentityEnhancement

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
      update_roles(subject)
      subject.update_attributes!(attrs.merge(complete: true))
      subject
    end

    private

    def finish(env)
      url = env['rack.session']['request_url'].to_s
      env['rack.session'].delete('request_url')

      return redirect_to(url) unless url.blank?
      super
    end

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

      fail("Incoming #{key} `#{incoming}` did not match existing `#{existing}`")
    end
  end
end
