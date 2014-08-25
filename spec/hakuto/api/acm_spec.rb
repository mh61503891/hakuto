require 'spec_helper'
require 'vcr'
require 'hakuto/api/acm'
require 'hakuto/models'

describe Hakuto::API::ACM do
  describe Hakuto::API::ACM::Reader, '#read' do
    subject(:reader) do
      Hakuto::API::ACM::Reader
    end
    context 'when paper does not exist' do
      it 'raises Exception' do
        VCR.use_cassette [:acm, 0] do
          expect{reader.read(0)}.to raise_error(Exception)
        end
      end
    end
    context 'when paper exists' do
      it 'does not raise Exception' do
        [1558031, 278941].each do |id|
          VCR.use_cassette [:acm, id] do
            expect{reader.read(id)}.to_not raise_error(Exception)
          end
        end
      end
      it 'returns a hash' do
        [1558031, 278941].each do |id|
          VCR.use_cassette [:acm, id] do
            expect(reader.read(id)).to be_a Hash
          end
        end
      end
      it 'returns a hash which is not empty' do
        [1558031, 278941].each do |id|
          VCR.use_cassette [:acm, id] do
            expect(reader.read(id)).to_not be_empty
          end
        end
      end
    end
  end
  describe Hakuto::API::ACM::Loader, '#load' do
    before do
      DataMapper.auto_migrate!
    end
    subject(:loader) do
      Hakuto::API::ACM::Loader
    end
    context 'when paper does not exist' do
      it 'raises Exception' do
        VCR.use_cassette [:acm, 0] do
          expect{loader.load(0)}.to raise_error(Exception)
        end
      end
    end
    context 'when paper exists' do
      it 'not raise Exception' do
        [1558031, 278941].each do |id|
          VCR.use_cassette [:acm, id] do
            expect{loader.load(id)}.to_not raise_error(Exception)
          end
        end
      end
      it 'returns a paper' do
        [1558031, 278941].each do |id|
          VCR.use_cassette [:acm, id] do
            expect(loader.load(id)).to be_a Hakuto::Paper
          end
        end
      end
    end
  end
end
