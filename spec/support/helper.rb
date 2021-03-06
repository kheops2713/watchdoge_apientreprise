def endpoints_count
  YAML.load_file('app/data/endpoints.yml').count
end

def valid_jti
  'd8cfec8b-9b00-471e-996d-6a1d93086e1c' # watchdoge JTI
end

def sorted_fake_calls(size: 10, oldest_timestamp: 8.days)
  endpoint_factory = EndpointFactory.new
  endpoints = endpoint_factory.endpoints.select { |e| e.api_name == 'apie' }
  fake_calls = []
  size.times do
    timestamp = time_rand(Time.zone.now - oldest_timestamp)
    source = fake_elk_source(endpoints.sample, timestamp)
    fake_calls << CallResult.new(source, endpoint_factory)
  end

  fake_calls.sort_by(&:timestamp)
end

def fake_elk_source(endpoint, timestamp, status = nil)
  {
    'path': endpoint.http_path,
    'status': status.nil? ? %w[200 206 400 404 500 501].sample : status,
    '@timestamp': timestamp.to_s,
    'parameters': { context: 'Ping', recipient: 'SGMAP', siret: '41816609600069', token: '[FILTERED]' },
    'response': {
      'provider_name': endpoint.provider,
      'fallback_used': [true, false].sample
    }
  }.stringify_keys
end

def time_rand(from = 0.0, to = Time.zone.now)
  Time.zone.at(from + rand * (to.to_f - from.to_f))
end
