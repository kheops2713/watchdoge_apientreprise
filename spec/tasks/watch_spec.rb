require 'rails_helper'

# rubocop:disable RSpec/MultipleDescribes
describe 'watch:period_1', vcr: { cassette_name: 'apie_all' } do
  include_context 'rake'

  after { Sidekiq::Worker.clear_all }

  context 'with all endpoints' do
    pending('Pb: certificates')
    # it 'exactly send 2 workers to sidekiq' do
    #   task.invoke
    #   expect { PingWorker.drain }.to change { PingWorker.jobs.size }.from(2).to(0)
    # end
  end
end

describe 'watch:period_5', vcr: { cassette_name: 'apie_all' } do
  include_context 'rake'

  after { Sidekiq::Worker.clear_all }

  context 'with all endpoints' do
    it 'exactly send 6 workers to sidekiq' do
      task.invoke
      expect { PingWorker.drain }.to change { PingWorker.jobs.size }.from(6).to(0)
    end
  end
end

describe 'watch:period_15', vcr: { cassette_name: 'apie_all' } do
  include_context 'rake'

  after { Sidekiq::Worker.clear_all }

  context 'with all endpoints' do
    it 'exactly send 2 workers to sidekiq' do
      task.invoke
      expect { PingWorker.drain }.to change { PingWorker.jobs.size }.from(2).to(0)
    end
  end
end

describe 'watch:period_60', vcr: { cassette_name: 'apie_all' } do
  include_context 'rake'

  after { Sidekiq::Worker.clear_all }

  context 'with all endpoints' do
    pending('Pb: certificates')
    # it 'exactly send 33 workers to sidekiq' do
    #   task.invoke
    #   expect { PingWorker.drain }.to change { PingWorker.jobs.size }.from(31).to(0)
    # end
  end
end
# rubocop:enable RSpec/MultipleDescribes