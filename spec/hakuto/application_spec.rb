require 'spec_helper'
require 'hakuto/application'
require 'hakuto/api/acm'
require 'hakuto/api/ieee'
require 'rack/test'

describe Hakuto::Application do
  include Rack::Test::Methods
  def app
    options = {
      root:File.expand_path('../../../', __FILE__),
      logging:true
    }
    Hakuto::Application.set(options)
  end
  before do
    DataMapper.auto_migrate!
  end
  describe '/' do
    subject { get('/') }
    it { is_expected.to be_ok }
  end
  describe '/lib/hakuto/index.css' do
    subject { get('/lib/hakuto/index.css') }
    it { is_expected.to be_ok }
  end
  describe '/paper.json' do
    context 'when valid params' do
      it 'returns 200' do
        [1558031, 278941].each do |id|
          VCR.use_cassette [:acm, id] do
            get('/paper.json', {acm_id:id})
            expect(last_response.status).to eql(200)
          end
        end
      end
    end
  end
end
