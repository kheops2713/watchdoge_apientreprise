require 'forwardable'

class Stats::JwtUsageService
  extend Forwardable
  delegate %i[success? errors] => :@client

  attr_reader :jti, :results, :hits

  def initialize(jti:)
    @hits = []
    @jti = jti
    @client = ElasticClient.new
    @client.establish_connection
  end

  def perform
    if @client.connected?
      retrieve_all_jwt_usage
      process_raw_response if @client.success?
    end

    self
  end

  private

  def process_raw_response
    @aggregator = Stats::JwtUsageAggregator.new(raw_data: @hits)
    @aggregator.aggregate
    @results = number_of_calls.merge(last_calls).merge(http_code_percentages)
  end

  def number_of_calls
    @aggregator.number_of_calls
  end

  def last_calls
    @aggregator.last_calls
  end

  def http_code_percentages
    @aggregator.http_code_percentages
  end

  def retrieve_all_jwt_usage
    loop do
      @client.perform json_query
      break unless @client.success?
      @hits.concat retrieved_hits
      @search_after = retrieved_hits.last['sort']
      break if retrieved_hits.count < 10_000
    end
  rescue Elasticsearch::Transport::Transport::Errors::BadRequest
    @success = false
  end

  def retrieved_hits
    @client.raw_response.dig('hits', 'hits')
  end

  def json_query
    query_hash.merge(search_after: @search_after).compact.to_json
  end

  def query_hash
    JSON.parse load_query
  end

  def load_query
    ERB.new(query_template).result(binding)
  end

  def query_template
    File.read('app/data/queries/' + query_name + '.json.erb')
  end

  # for specs
  def query_name
    'jwt_usage'
  end
end