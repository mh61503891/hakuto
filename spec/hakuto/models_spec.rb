require 'spec_helper'

include Hakuto
describe Paper do
  describe '#sachertorte' do
    it 'must be delicious ;)' do
      # init the contents of the database
      DataMapper.auto_migrate!
      stuffs = [
        cacao = Paper.new(acm_title:'cacao'),
        sugar = Paper.new(acm_title:'sugar'),
        butter = Paper.new(acm_title:'butter'),
        milk = Paper.new(acm_title:'milk'),
        chocolate = Paper.new(acm_title:'chocolate'),
        flour = Paper.new(acm_title:'flour'),
        egg = Paper.new(acm_title:'egg'),
        cream = Paper.new(acm_title:'cream'),
        cake = Paper.new(acm_title:'cake'),
        sachertorte = Paper.new(acm_title:'sachertorte')
      ]
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
      expect(Paper.count).to be stuffs.size
    end
  end
end
