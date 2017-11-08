require 'spec_helper'
require 'svar'

Thread.abort_on_exception = true

describe ":frozen" do
  [:read_only, :write_once, :mutable].each do |type|
    context "#{type}" do
      it "ne demarre l'evaluation que lorsqu'on demande la valeur (de facon paresseuse)" do
        sv = SVar.new( type, :frozen ) { sleep DELAY; 99 }
        sleep DELAY

        val = nil
        lambda { val = sv.value }.must_be_delayed(DELAY)

        val.must_equal 99
      end

      it "permet de construire un objet defini recursivement" do
        deux2 = [2, SVar.new( type, :frozen ) { deux2.first }]

        value =  ->(x) { x.respond_to?(:value) ? x.value : x }
        deux2.map(&value).must_equal [2, 2]
      end
    end
  end

  context ":read_only" do
    it "ne permet pas l'ecriture" do
      sv = SVar.new( :read_only, :frozen ) { 99 }

      lambda { sv.value = 0 }.must_raise NoMethodError
      sv.value.must_equal 99
    end
  end

  context ":write_once" do
    it "ne permet pas l'ecriture car deja definie" do
      sv = SVar.new( :write_once, :frozen ) { 99 }

      lambda { sv.value = 0 }.must_raise RuntimeError

      sv.value.must_equal 99
    end
  end

  context ":mutable" do
    describe "#take" do
      it "lance l'evaluation" do
        sv = SVar.new( :mutable, :frozen ) { sleep DELAY; 99 }

        t = Thread.new { sv.take }
        sleep DELAY / 2
        assert sv.state == :in_evaluation

        t.value.must_equal 99
        assert sv.empty?
      end
    end
  end
end
