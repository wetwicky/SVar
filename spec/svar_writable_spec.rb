require 'spec_helper'
require 'svar'

Thread.abort_on_exception = true

describe SVar::SVarWritable do
  context :write_once do
    it "definit le resultat pour value" do
      sv = SVar.new( :write_once )
      sv.value = 111

      sv.value.must_equal 111
    end

    it "suspend le lecteur lorsque la valeur n'est pas disponible" do
      sv = SVar.new( :write_once )
      thr = Thread.new { sleep DELAY; sv.value = 99 }

      val = nil
      lambda { val = sv.value }.must_be_delayed(DELAY)

      val.must_equal 99
      thr.value.must_equal 99
    end

    it "ne permet pas l'ecriture lorsque deja definie" do
      sv = SVar.new( :write_once )
      sv.value = 99

      lambda { sv.value = 20 }.must_raise RuntimeError
    end

    it "retourne la valeur affectee" do
      sv = SVar.new( :write_once )
      (sv.value = 9999).must_equal 9999
    end
  end
end
