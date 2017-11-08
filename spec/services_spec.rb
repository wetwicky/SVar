require 'spec_helper'
require 'svar'
require 'bin/services'

Thread.abort_on_exception = true

def int2id( k )
  "#{k}".to_sym
end

NB_FOURNISSEURS = 4
NB_AGENCES = 3

FOURNISSEURS = [*0...NB_FOURNISSEURS]
AGENCES = [*0...NB_AGENCES]

module ServicesExternesBidons
  def self.prix_et_qte_disponible( fournisseur, item_desire, qte_desiree )
    sleep rand(10) / 20.0
    prix = [100, 90, 80, *Array.new(NB_FOURNISSEURS-3) { 120 }]
    qte = [qte_desiree, qte_desiree, qte_desiree - 1, *Array.new(NB_FOURNISSEURS-3) { qte_desiree }]

    [prix[fournisseur], qte[fournisseur]]
  end

  def self.paiement_ok?( agence, id_usager, montant )
    sleep rand(10) / 10.0
    agence == 0
  end
end

module ServicesExternesBidonsAvecDelais
  def self.prix_et_qte_disponible( fournisseur, item_desire, qte_desiree )
    sleep DELAY

    [0, qte_desiree]
  end

  def self.paiement_ok?( agence, id_usager, montant )
    sleep DELAY
    agence == NB_AGENCES - 1 ? true : false
  end
end

TRAITER_REQUETES = [
                    TraiterRequeteSeq,
                    TraiterRequeteThread,
                    TraiterRequeteSVar,
                   ]

DELAIS = {
  TraiterRequeteSeq: NB_FOURNISSEURS * DELAY + NB_AGENCES * DELAY,
  TraiterRequeteThread: DELAY + DELAY,
  TraiterRequeteSVar: DELAY + DELAY,
}

describe SVar do
  context "bin/services.rb utilise via ses methodes" do
    context "sans traitement des delais" do
      TRAITER_REQUETES.each do |traiter_requete|
        it "produit le bon resultat avec #{traiter_requete}" do
          traiter_requete.services_externes = ServicesExternesBidons
          traiter_requete.run( 0, 10, 9999 ).must_equal [1, 90, 0]
        end
      end
    end

    context "avec traitement des delais" do
      TRAITER_REQUETES.each do |traiter_requete|
        it "produit le bon delai pour #{traiter_requete}" do
          traiter_requete.services_externes = ServicesExternesBidonsAvecDelais
          delai = DELAIS[traiter_requete.to_s.to_sym]

          lambda { traiter_requete.run( 0, 10, 9999 ) }.must_be_delayed delai
        end
      end
    end
  end
end
