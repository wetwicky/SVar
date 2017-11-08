require 'spec_helper'
require 'svar'

Thread.abort_on_exception = true

describe SVar::SVar do
  describe "#eval" do
    it "ne bloque pas" do
      sv = SVar.new( :read_only, :frozen ) { sleep DELAY; 99 }
      lambda { sv.eval }.wont_be_delayed
    end

    it "force l'evaluation" do
      sv = SVar.new( :read_only, :frozen ) { sleep DELAY; 99 }
      sv.eval

      val = nil
      lambda { val = sv.value }.must_be_delayed(DELAY)
      val.must_equal 99
    end

    it "n'a aucun effet si deja evaluee" do
      sv = SVar.new( :read_only, :frozen ) { sleep DELAY; 99 }
      sv.value

      lambda { sv.eval }.wont_be_delayed
      lambda { sv.value }.wont_be_delayed
    end

    it "n'a aucun effet si autre que frozen, en autant que pas vide" do
      sv = SVar.new( :read_only, :immediate ) { 99 }
      lambda { sv.eval }.wont_be_delayed

      sv = SVar.new( :read_only, :async ) { 99 }
      lambda { sv.eval }.wont_be_delayed

      sv = SVar.new( :write_once, :immediate ) { 99 }
      lambda { sv.eval }.wont_be_delayed

      sv = SVar.new( :write_once, :async ) { 99 }
      lambda { sv.eval }.wont_be_delayed

      sv = SVar.new( :mutable, :immediate ) { 99 }
      lambda { sv.eval }.wont_be_delayed

      sv = SVar.new( :mutable, :async ) { 99 }
      lambda { sv.eval }.wont_be_delayed
    end

    it "genere une exception si vide" do
      sv = SVar.new( :write_once )
      lambda { sv.eval }.must_raise RuntimeError

      sv = SVar.new( :mutable )
      lambda { sv.eval }.must_raise RuntimeError
    end
  end
end
