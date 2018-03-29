class ElasticClient
  attr_reader :connected, :success, :raw_response, :errors
  alias success? success
  alias connected? connected

  def initialize
    @errors = []
    @success = false
    @connected = false
  end

  def establish_connection
    @client = Elasticsearch::Client.new host: 'watchdoge.entreprise.api.gouv.fr', log: false
    @client.transport.reload_connections!
    @connected = true
  rescue Faraday::TimeoutError
    @errors << 'Timeout error, connection may not be allowed'
  rescue Faraday::ConnectionFailed # TODO: need specs here
    @errors << 'Connection to Watchdoge server failed'
  end

  def perform(json_query)
    try_to_perform(json_query) if connected?
  end

  private

  def try_to_perform(json_query)
    @raw_response = @client.search body: json_query
    @success = true
  rescue Elasticsearch::Transport::Transport::Errors::BadRequest
    @errors << 'Elasticsearch BadRequest'
  end
end