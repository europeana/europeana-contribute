# encoding: utf-8

RSpec.describe Mongoid::Relations::AutoSave do
  context 'when relation is has_one' do
    before(:all) do
      module Dummy
        class A
          include Mongoid::Document
          field :af, type: String
          has_one :b, class_name: 'Dummy::B', autosave: true, inverse_of: :a
        end

        class B
          include Mongoid::Document
          field :bf, type: String
          belongs_to :a, class_name: 'Dummy::A', inverse_of: :b, optional: true
          has_one :c, class_name: 'Dummy::C', autosave: true, inverse_of: :b
          has_one :d, class_name: 'Dummy::D', autosave: false, inverse_of: :b
        end

        class C
          include Mongoid::Document
          field :cf, type: String
          belongs_to :b, class_name: 'Dummy::B', inverse_of: :c, optional: true
        end

        class D
          include Mongoid::Document
          field :df, type: String
          belongs_to :b, class_name: 'Dummy::B', inverse_of: :d, optional: true
        end
      end
    end

    after(:all) do
      Object.send(:remove_const, :Dummy)
    end

    context 'with autosave: true' do
      it 'autosaves across relations' do
        c = Dummy::C.create!
        b = Dummy::B.create!(c: c)
        a = Dummy::A.create!(b: b)
        c.cf = 'val'
        a.save
        expect(c.reload.cf).to eq('val')
      end
    end

    context 'with autosave: false' do
      it 'does not autosave across relations' do
        d = Dummy::D.create!
        b = Dummy::B.create!(d: d)
        a = Dummy::A.create!(b: b)
        d.df ='val'
        a.save
        expect(d.reload.df).not_to eq('val')
      end
    end
  end

  context 'when relation is has_many' do
    before(:all) do
      module Dummy
        class A
          include Mongoid::Document
          field :af, type: String
          has_many :b, class_name: 'Dummy::B', autosave: true, inverse_of: :a
        end

        class B
          include Mongoid::Document
          field :bf, type: String
          belongs_to :a, class_name: 'Dummy::A', inverse_of: :b, optional: true
          has_many :c, class_name: 'Dummy::C', autosave: true, inverse_of: :b
          has_many :d, class_name: 'Dummy::D', autosave: false, inverse_of: :b
        end

        class C
          include Mongoid::Document
          field :cf, type: String
          belongs_to :b, class_name: 'Dummy::B', inverse_of: :c, optional: true
        end

        class D
          include Mongoid::Document
          field :df, type: String
          belongs_to :b, class_name: 'Dummy::B', inverse_of: :d, optional: true
        end
      end
    end

    after(:all) do
      Object.send(:remove_const, :Dummy)
    end

    context 'with autosave: true' do
      it 'autosaves across relations' do
        c = Dummy::C.create!
        b = Dummy::B.create!(c: [c])
        a = Dummy::A.create!(b: [b])
        c.cf = 'val'
        a.save
        expect(c.reload.cf).to eq('val')
      end
    end

    context 'with autosave: false' do
      it 'does not autosave across relations' do
        d = Dummy::D.create!
        b = Dummy::B.create!(d: [d])
        a = Dummy::A.create!(b: [b])
        d.df ='val'
        a.save
        expect(d.reload.df).not_to eq('val')
      end
    end
  end

  context 'when relation is belongs_to' do
    before(:all) do
      module Dummy
        class A
          include Mongoid::Document
          field :af, type: String
          belongs_to :b, class_name: 'Dummy::B', autosave: true, inverse_of: :a, optional: true
        end

        class B
          include Mongoid::Document
          field :bf, type: String
          has_one :a, class_name: 'Dummy::A', inverse_of: :b
          belongs_to :c, class_name: 'Dummy::C', autosave: true, inverse_of: :b, optional: true
          belongs_to :d, class_name: 'Dummy::D', autosave: false, inverse_of: :b, optional: true
        end

        class C
          include Mongoid::Document
          field :cf, type: String
          has_one :b, class_name: 'Dummy::B', inverse_of: :c
        end

        class D
          include Mongoid::Document
          field :df, type: String
          has_one :b, class_name: 'Dummy::B', inverse_of: :d
        end
      end
    end

    after(:all) do
      Object.send(:remove_const, :Dummy)
    end

    context 'with autosave: true' do
      it 'autosaves across relations' do
        c = Dummy::C.create!
        b = Dummy::B.create!(c: c)
        a = Dummy::A.create!(b: b)
        c.cf = 'val'
        c.save!
        expect(c.reload.cf).to eq('val')
      end
    end

    context 'with autosave: false' do
      it 'does not autosave across relations' do
        d = Dummy::D.create!
        b = Dummy::B.create!(d: d)
        a = Dummy::A.create!(b: b)
        d.df = 'val'
        a.save!
        expect(d.reload.df).not_to eq('val')
      end
    end
  end

  context 'when relation is has_and_belongs_to_many' do
    before(:all) do
      module Dummy
        class A
          include Mongoid::Document
          field :af, type: String
          has_and_belongs_to_many :b, class_name: 'Dummy::B', autosave: true, inverse_of: :a
        end

        class B
          include Mongoid::Document
          field :bf, type: String
          has_and_belongs_to_many :a, class_name: 'Dummy::A', inverse_of: :b
          has_and_belongs_to_many :c, class_name: 'Dummy::C', autosave: true, inverse_of: :b
          has_and_belongs_to_many :d, class_name: 'Dummy::D', autosave: false, inverse_of: :b
        end

        class C
          include Mongoid::Document
          field :cf, type: String
          has_and_belongs_to_many :b, class_name: 'Dummy::B', inverse_of: :c
        end

        class D
          include Mongoid::Document
          field :df, type: String
          has_and_belongs_to_many :b, class_name: 'Dummy::B', inverse_of: :d
        end
      end
    end

    after(:all) do
      Object.send(:remove_const, :Dummy)
    end

    context 'with autosave: true' do
      it 'autosaves across relations' do
        c = Dummy::C.create!
        b = Dummy::B.create!(c: [c])
        a = Dummy::A.create!(b: [b])
        c.cf = 'val'
        a.save
        expect(c.reload.cf).to eq('val')
      end
    end

    context 'with autosave: false' do
      it 'does not autosave across relations' do
        d = Dummy::D.create!
        b = Dummy::B.create!(d: [d])
        a = Dummy::A.create!(b: [b])
        d.df ='val'
        a.save
        expect(d.reload.df).not_to eq('val')
      end
    end
  end
end
