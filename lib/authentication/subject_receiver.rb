module Authentication
  class SubjectReceiver
    include RapidRack::DefaultReceiver
    include RapidRack::RedisRegistry

    def map_attributes(_env, attrs)
      {
        targeted_id: attrs['edupersontargetedid'],
        shared_token: attrs['auedupersonsharedtoken'],
        name: attrs['displayname'],
        email: attrs['mail']
      }
    end

    def subject(_env, _attrs)
      fail('not implemented')
    end
  end
end
