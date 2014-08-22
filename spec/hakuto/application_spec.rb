require 'spec_helper'
require 'rack/test'
# require 'json_spec'

describe Hakuto::Application do

  include Rack::Test::Methods

  def app
    options = {
      root:File.expand_path('../../../', __FILE__)
    }
    Hakuto::Application.set(options)
  end

  describe '/' do
    subject { get('/') }
    it { is_expected.to be_ok }
  end

  describe '/paper.json' do
    context 'when valid params' do
      it 'returns 200' do
        expect(get('/paper.json', {type:'acm', id:1}).status).to eql(200)
      end
      subject do
        get('/paper.json', {
              type:'acm',
              id:1
        }).body
      end
      it { is_expected.to have_json_path('id') }
    end
    context 'when invalid params' do
      it 'returns 400' do
        expect(get('/paper.json').status).to eql(400)
        expect(get('/paper.json', {id:1}).status).to eql(400)
        expect(get('/paper.json', {type:'acm'}).status).to eql(400)
        expect(get('/paper.json', {type:'piyo', id:1}).status).to eql(400)
      end
    end

    # subject {
    #   get('/api/papers/', {
    #         type:'acm',
    #         id:1
    #   }).body
    # }
  end
end
