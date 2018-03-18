require 'action_view'

class Stats::CallCounter
  include ActionView::Helpers::DateHelper

  attr_reader :duration, :beginning_timestamp, :endpoints

  EndpointCallCounter = Struct.new(:endpoint, :count) do
    def as_json
      {
        uname: endpoint.uname,
        name: endpoint.name,
        total: count
      }
    end
  end

  def initialize(duration:, beginning_timestamp:)
    @duration = duration
    @beginning_timestamp = beginning_timestamp
    @endpoints = []
  end

  def add(call_characteristics)
    endpoint = @endpoints.find { |e| e.endpoint.uname == call_characteristics.uname }
    if endpoint.nil?
      @endpoints << EndpointCallCounter.new(call_characteristics, 1)
    else
      endpoint.count += 1
    end
  end

  def total
    @endpoints.map(&:count).inject(0, &:+)
  end

  def as_json
    {
      "last_#{duration_name}": {
        total: total,
        by_endpoint: @endpoints.as_json
      }
    }
  end

  private

  def duration_name
    distance_of_time_in_words(@duration).parameterize.underscore
  end
end