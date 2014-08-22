require 'spec_helper'

include Hakuto::API::ACM
describe Hakuto::API::ACM do
  include Rack::Test::Methods
  def app
    options = {
      public_folder:File.expand_path('../mock/acm', __FILE__)
    }
    Sinatra::Application.set(options)
  end
  def uri
    "http://#{app.bind}:#{app.port}"
  end
  subject(:adapter) do
    adapter = Hakuto::API::ACM::Adapter.new
    adapter.routers = {
      citation:lambda{ |id| "#{uri}/#{id}_citation.html" },
      abstract:lambda{ |id| "#{uri}/#{id}_abstract.html" },
      references:lambda{ |id| "#{uri}/#{id}_references.html" },
      citings:lambda{ |id| "#{uri}/#{id}_citings.html" }
    }
    adapter.getter = lambda{ |uri|
      return get(uri).body
    }
    adapter
  end
  describe Adapter, '#get' do
    context 'when paper does not exist' do
      it 'returns nil' do
        expect(adapter.get(0)).to be_empty
        expect(adapter.get(9999999)).to be_empty
      end
    end
    context 'when paper exists' do
      it 'not raise Exception' do
        expect{
          adapter.get(1558031)
        }.to_not raise_error(Exception)
        expect{
          adapter.get(278941)
        }.to_not raise_error(Exception)
      end
    end
  end
  describe Loader, '#load' do
    before(:all) do
      DataMapper.auto_migrate!
    end
    after(:all) do
      DataMapper.auto_migrate!
    end
    context 'when paper does not exist' do
      it 'not raise Exception' do
        expect{
          loader = Hakuto::API::ACM::Loader.new
          loader.adapter = adapter
          loader.load(0)
        }.to_not raise_error(Exception)
      end
      it 'returns nil' do
        loader = Hakuto::API::ACM::Loader.new
        loader.adapter = adapter
        expect(loader.load(0)).to be nil
      end
    end
    context 'when paper exists' do
      it 'not raise Exception' do
        expect{
          loader = Hakuto::API::ACM::Loader.new
          loader.adapter = adapter
          loader.load(1558031)
        }.to_not raise_error(Exception)
        expect{
          loader = Hakuto::API::ACM::Loader.new
          loader.adapter = adapter
          loader.load(278941)
        }.to_not raise_error(Exception)
      end
    end
    context 'at the end of this test' do
      it 'adds 101 papers' do
        expect(Paper.count).to be == (27 + 74 + 0)
      end
      it 'adds 99 links' do
        expect(Link.count).to be == (26 + 73 + 0)
      end
    end
  end
end
