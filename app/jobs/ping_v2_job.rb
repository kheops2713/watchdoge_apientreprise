class PingV2Job < ApplicationJob
  include HTTParty

  attr_reader :pings

  base_uri Rails.application.config_for(:watchdoge_secrets)['apie_base_uri']

  def initialize
    super
    @pings = []
  end

  def perform
    @pings.clear

    endpoints_v2.each do |endpoint|
      ping = PingStatus.new(
        name: endpoint.name,
        api_version: 2,
        status: get_service_status(endpoint),
        date: DateTime.now
      )

      if ping.valid?
        @pings << ping
        Tools::PingReaderWriter.new.write(ping)
        log(ping)
      else
        Rails.logger.error "Fail to write PingStatus(#{ping.name}) it's invalid (#{ping.errors.messages})"
      end
    end
  end

  private

  def get_service_status(endpoint)
    response = perform_service(endpoint)
    response.code == 200 ? 'up' : 'down'
  end

  def perform_service(endpoint)
    self.class.get(request_url(endpoint))
  end

  def request_url(endpoint)
    "/v2/#{endpoint.name}/#{endpoint.parameter}?token=#{apie_token}&#{endpoint.options.to_param}"
  end

  def log(ping)
    logger.info({
      endpoint: ping.name,
      status: ping.status,
      date: ping.date
    })
  end

  def apie_token
    Rails.application.config_for(:watchdoge_secrets)['apie_token']
  end

  def endpoints_v2
    Tools::EndpointFactory.new.load_all
  end
end