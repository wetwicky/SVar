require 'spec_helper'
require 'svar'

Thread.abort_on_exception = true

describe SVar::SVarMutable do
  context :mutable do
    it "peut etre initialise" do
      sv = SVar.new( :mutable, :immediate ) { 111 }

      sv.value.must_equal 111
    end

    it "permet d'utiliser value= pour definir le resultat de value" do
      sv = SVar.new( :mutable )
      sv.value = 111

      sv.value.must_equal 111
    end

    it "suspend le lecteur lorsque la valeur n'est pas disponible" do
      sv = SVar.new( :mutable ) { sleep DELAY; 99 }

      val = nil
      lambda { val = sv.value }.must_be_delayed(DELAY)

      val.must_equal 99
    end

    it "ne permet pas l'ecriture lorsque deja definie" do
      sv = SVar.new( :mutable, :immediate ) { 99 }

      lambda { sv.value = 20 }.must_raise RuntimeError
    end

    describe "#take" do
      let(:sv) { SVar.new( :mutable ) }

      it "retourne la valeur conservee" do
        sv.value = 99

        sv.take.must_equal 99
      end

      it "ne bloque pas si deja pleine" do
        sv.value = 99

        lambda{ sv.take }.wont_be_delayed
      end

      it "bloque si vide jusqu'a ce que pleine" do
        Thread.new { sleep DELAY; sv.value = 99 }

        lambda{ sv.take }.must_be_delayed(DELAY)
      end

      it "retire la valeur donc fait devenir empty, ce qui bloque les lecteurs" do
        sv.value = 99

        lambda{ sv.value }.wont_be_delayed

        sv.take
        Thread.new { sleep DELAY; sv.value = 123 }
        lambda { sv.value }.must_be_delayed(DELAY)
      end
    end

    describe "#mutate!" do
      let(:sv) { SVar.new( :mutable ) }

      it "modifie la variable lorsque deja pleine" do
        sv.value = 99

        sv.mutate! { |v| v + 1 }
        sv.value.must_equal 100
      end

      it "retourne la nouvelle valeur" do
        sv.value = 99

        sv.mutate! { |v| v + 1 }.must_equal 100
      end

      it "ne bloque pas si deja pleine" do
        sv.value = 99

        lambda { sv.mutate! { |v| v + 1 } }.wont_be_delayed
      end

      it "bloque si vide jusqu'a ce que pleine" do
        Thread.new { sleep DELAY; sv.value = 99 }

        lambda { sv.mutate! { |v| v + 1 } }.must_be_delayed(DELAY)
      end

      it "assure l'execution atomique" do
        sv.value = 0

        n = 100
        threads = (0...n).map do |k|
          Thread.new { sv.mutate! { |x| x + 1 } }
        end

        threads.map(&:value).sort.must_equal [*1...n+1]
        sv.value.must_equal n
      end
    end
  end
end
