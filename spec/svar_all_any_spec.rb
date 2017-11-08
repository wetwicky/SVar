require 'spec_helper'
require 'svar'

Thread.abort_on_exception = true

# Par defaut, les variables sont :write_once et :async. Donc, dans
# tous les exemples ci-bas, aucun argument n'est indique pour new.

describe SVar::SVarWritable do
  describe ".all" do
    it "obtient trois resultats et produit un tableau des valeurs obtenues" do
      sv1 = SVar.new { 1 }
      sv2 = SVar.new { 2 }
      sv3 = SVar.new { 3 }

      SVar.all( sv1, sv2, sv3 ).value.must_equal [1, 2, 3]
    end

    it "produit un SVar, qui peut etre consomme par un then" do
      sv1 = SVar.new { 1 }
      sv2 = SVar.new { 2 }
      sv3 = SVar.new { 3 }

      SVar.all( sv1, sv2, sv3 ).then { |x, y, z| x + y + z }.value.must_equal 6
    end

    it "attend deux resultats lents, donc en bloquant si necessaire" do
      sv1 = SVar.new { sleep DELAY; 1 }
      sv2 = SVar.new { sleep 0.5 * DELAY; 2 }

      v = nil
      lambda { v = SVar.all( sv1, sv2 ).value }.must_be_delayed(DELAY)
      v.must_equal [1, 2]
    end

    it "produit un grand nombre de resultats sans delai" do
      n = 99  # Si n trop grand, cree probleme de threads :(
      svs = (0..n).map { |k| SVar.new { k } }

      v = nil
      lambda { v = SVar.all( *svs ).value }.wont_be_delayed
      v.must_equal [*0..n]
    end

    it "produit un grand nombre de resultats avec delais" do
      n = 99  # Si n trop grand, cree probleme de threads :(
      svs = (0..n).map { |k| SVar.new { sleep DELAY; k } }

      v = nil
      lambda { v = SVar.all( *svs ).value }.must_be_delayed(DELAY)
      v.must_equal [*0..n]
    end
  end

  describe ".any" do
    it "obtient le premier resultat disponible parmi trois et le retourne" do
      sv1 = SVar.new { sleep DELAY; 1 }
      sv2 = SVar.new { 2 }
      sv3 = SVar.new { sleep DELAY; 3 }

      sv = SVar.any( sv1, sv2, sv3 )

      v = nil
      lambda { v = sv.value }.wont_be_delayed
      v.must_equal 2
    end

    it "obtient le premier resultat disponible parmi trois, en bloquant si necessaire" do
      sv1 = SVar.new { sleep DELAY; 1 }
      sv2 = SVar.new { sleep DELAY/2.0; 2 }
      sv3 = SVar.new { sleep DELAY; 3 }

      sv = SVar.any( sv1, sv2, sv3 )

      v = nil
      lambda { v = sv.value }.must_be_delayed( DELAY / 2.0 )
      v.must_equal 2
    end

    it "obtient un resultat parmi plusieurs, sans bloquer" do
      n = 39
      svs = (0..n).map { |k| SVar.new { k } }

      v = nil
      lambda { v = SVar.any( *svs ).value }.wont_be_delayed
      assert [*0..n].include?(v)
    end

    it "obtient un resultat parmi plusieurs, en bloquant si necessaire" do
      n = 39
      svs = (0..n).map { |k| SVar.new { sleep DELAY; k } }

      v = nil
      lambda { v = SVar.any( *svs ).value }.must_be_delayed(DELAY)
      assert [*0..n].include?(v)
    end
  end
end
