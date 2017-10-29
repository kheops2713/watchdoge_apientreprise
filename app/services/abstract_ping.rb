class AbstractPing
  include HTTParty

  def perform
    Tools::PingWorker.new(endpoints) do |endpoint|
      ping = perform_ping(endpoint)
      yield ping, endpoint if block_given?
    end
  end

  # rubocop:disable MethodLength
  def perform_ping(endpoint)
    http_response = get_http_response(endpoint)

    ping = PingStatus.new(
      name: endpoint.fullname,
      http_response: http_response
    )

    if (ping.status != 'up')
      PingMailer.ping(ping, endpoint).deliver_now
    end

    ping
  end

  protected

  def request_url(endpoint)
    fail 'should implement request_url'
  end

  def endpoints
    fail 'should implement endpoints'
  end

  private

  def get_http_response(endpoint)
    self.class.get(request_url(endpoint))
  end
end