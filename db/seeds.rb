unless ENV['AAF_DEV'].to_i == 1
  $stderr.puts <<-EOF

  This is a destructive action, intended only for use in development
  environments where you wish to replace ALL data with generated sample data.

  If this is what you want, set the AAF_DEV environment variable to 1 before
  attempting to seed your database.

  EOF
  fail('Not proceeding, missing AAF_DEV=1 environment variable')
end

require 'faker'

def idps
  @idps ||= (1..50).to_a.map do
    "https://idp.#{Faker::Internet.domain_name}/idp/shibboleth"
  end
end

def sps
  @sps ||= (1..100).to_a.map do
    "https://sp.#{Faker::Internet.domain_name}/shibboleth"
  end
end

def progress(kind, n)
  print "\rCreating #{kind}... #{n}\e[0K"
end

def event_body(time)
  idp = idps.sample
  sp = sps.sample

  return_url = sp.gsub(%r{/shibboleth$}, '/Shibboleth.sso/SSO')

  doc = { idp: idp, sp: sp, return_url: return_url, date: time.xmlschema,
          ip: Faker::Internet.ip_v4_address, protocol: 'DS', type: 'Cookie' }
end

include DataSources
index = elasticsearch_index
client = elasticsearch_client

type_mappings = { ds: { _ttl: { enabled: false } } }

client.indices.delete(index: index)
client.indices.create(index: index, body: { mappings: type_mappings })

times = Enumerator.new do |y|
  ((Date.today - 40)..Date.tomorrow).to_a.each do |date|
    i = 0

    while i < 86_400
      i += rand(300)
      y << i.seconds.since(date)
    end
  end
end

n = 0
times.map { |t| event_body(t) }.each_slice(50) do |slice|
  progress('events', (n += slice.length))
  body = slice.map { |doc| { create: { data: doc } } }
  client.bulk(index: index, type: 'ds', body: body)
end
puts
