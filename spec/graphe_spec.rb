require 'spec_helper'
require 'svar'
require 'bin/graphe'

Thread.abort_on_exception = true

def int2id( k )
  "#{k}".to_sym
end

NOEUDS = [
          NoeudSeq,
          NoeudPar,
         ]

describe SVar do
  context "bin/graphe.rb utilise via ses methodes" do
    NOEUDS.each do |sorte_noeud|
      describe "un petit exemple de graphe connexe avec trois noeuds" do
        before do
          @gr = Graphe.new( sorte_noeud,
                            { n1: [10, [:n2, :n3]],
                              n2: [20, [:n3]],
                              n3: [30, [:n1, :n3]],
                            }
                            )
        end

        [:n1, :n2, :n3].each do |n|
          it "produit le bon resultat a partir du noeud #{n}" do
            @gr[n].somme.must_equal 60
          end

          it "produit le bon resultat a partir du noeud #{n} et ce apres avoir resette les marques" do
            @gr[n].somme.must_equal 60

            @gr.reset_marques
            @gr[n].somme.must_equal 60
          end
        end
      end

      describe "un graphe complet avec un grand nombre de noeuds" do
        it "produit le bon resultat a partir de n'importe quel noeud" do
          n = 100

          # On cree le graphe.
          symboles = Array.new(n) { |k| int2id(k) }

          noeuds = {}
          (0...n).each { |k| noeuds[int2id(k)] = [k, symboles] }
          gr = Graphe.new( sorte_noeud, noeuds )

          # On evalue sa somme a partir d'un noeud arbitraire.
          gr[int2id(rand n)].somme.must_equal [*0...n].reduce(&:+)
        end
      end

      describe "un anneau circulaire avec des boucles sur chaque noeud" do
        it "produit le bon resultat a partir de n'importe quel noeud" do
          n = 100

          # On cree le graphe.
          symboles = Array.new(n) { |k| int2id(k) }

          noeuds = {}
          symboles.each_with_index do |id, k|
            id_suiv = int2id( (k+1) % n )
            noeuds[id] = [k, [id,     # Boucle sur le noeud.
                              id_suiv # Voisin dans l'anneau
                             ]]
          end
          gr = Graphe.new( sorte_noeud, noeuds )

          # On evalue sa somme a partir d'un noeud arbitraire.
          gr[int2id(rand n)].somme.must_equal [*0...n].reduce(&:+)
        end
      end
    end
  end
end
