require 'spec_helper'
require 'svar'

Thread.abort_on_exception = true

describe SVar::SVar do
  context :immediate do
    it "ne bloque pas le lecteur puisque la valeur est deja prete" do
      sv = SVar.new( :read_only, :immediate ) { sleep DELAY; 99 }

      val = nil
      lambda { val = sv.value }.wont_be_delayed

      val.must_equal 99
    end

    it "ne permet pas l'ecriture puisque deja definie" do
      sv = SVar.new( :read_only, :immediate ) { 99 }

      lambda { sv.value = 0 }.must_raise NoMethodError
      sv.value.must_equal 99
    end

    it "ne permet pas de prendre la valeur" do
      sv = SVar.new( :read_only, :immediate ) { 99 }

      val = nil
      lambda { val = sv.take }.must_raise NoMethodError
      val.must_equal nil
    end
  end

  context :async do
    it "bloque le lecteur tant que la valeur n'est pas prete" do
      sv = SVar.new( :read_only, :async ) { sleep DELAY; 99 }

      val = nil
      lambda { val = sv.value }.must_be_delayed(DELAY)

      val.must_equal 99
    end

    it "ne permet pas l'ecriture puisque deja definie" do
      sv = SVar.new( :read_only, :async ) { 99 }

      lambda { sleep DELAY; sv.value = 0 }.must_raise NoMethodError
      sv.value.must_equal 99
    end

    it "ne permet pas de prendre la valeur" do
      sv = SVar.new( :read_only, :async ) { 99 }

      val = nil
      lambda { val = sv.take }.must_raise NoMethodError
      val.must_equal nil
    end
  end
end
