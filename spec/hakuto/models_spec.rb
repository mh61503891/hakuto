require 'spec_helper'
require 'hakuto/models'

describe Hakuto::Paper do
  describe '#sachertorte' do
    it 'must be delicious ;)' do
      # init the contents of the database
      DataMapper.auto_migrate!
      stuffs = [
        cacao = Hakuto::Paper.new(acm_title:'cacao'),
        sugar = Hakuto::Paper.new(acm_title:'sugar'),
        butter = Hakuto::Paper.new(acm_title:'butter'),
        milk = Hakuto::Paper.new(acm_title:'milk'),
        chocolate = Hakuto::Paper.new(acm_title:'chocolate'),
        flour = Hakuto::Paper.new(acm_title:'flour'),
        egg = Hakuto::Paper.new(acm_title:'egg'),
        cream = Hakuto::Paper.new(acm_title:'cream'),
        cake = Hakuto::Paper.new(acm_title:'cake'),
        sachertorte = Hakuto::Paper.new(acm_title:'sachertorte')
      ]
      cake.references << butter # ;)
      cake.references << butter
      cake.references << sugar
      cake.references << egg
      cake.references << flour
      chocolate.references << butter
      chocolate.references << sugar
      chocolate.references << milk
      chocolate.references << cacao
      cream.references << milk
      sachertorte.references << cake
      sachertorte.references << chocolate
      sachertorte.references << cream
      expect(sachertorte.save).to be true
      expect(Hakuto::Paper.count).to be stuffs.size
    end
  end
end
