module DataSources
  def elasticsearch_client
    @elasticsearch_client ||=
      Elasticsearch::Client.new(elasticsearch_config.slice(:url))
  end

  def elasticsearch_index
    @elasticsearch_index ||= elasticsearch_config[:index]
  end

  private

  def elasticsearch_config
    Rails.application.config.elasticsearch
  end
end
