module IdentityEnhancementStub
  def stub_ide(shared_token:, entitlements: [], **)
    host = Rails.application.config.reporting_service.ide[:host]
    url =  "https://#{host}/api/subjects/#{shared_token}/attributes"

    attrs = entitlements.map { |v| { name: 'eduPersonEntitlement', value: v } }
    stub_request(:get, url)
      .to_return(status: 200, body: JSON.generate(attributes: attrs))
  end
end
