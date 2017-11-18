#!/usr/bin/env ruby

#
# Module pour definir des graphes et effectuer un parcours pour
# calculer la somme des noeuds du graphe.
#

require 'pruby'
require_relative "../lib/svar"

Thread.abort_on_exception = true

#
# Classe pour des graphes diriges representes via des listes
# d'adjacences, i.e., a chaque noeud est associe la liste des noeuds
# qui lui sont adjacents, via un arc.
#
class Graphe
  #
  # Cree un nouveau graphe.
  #
  # @param [NoeudSeq, NoeudPar] type type/classe des noeuds du graphe
  # @param [Hash<Symbol, Array<Fixnum, Array<type>>>] noeuds un hash donnant les noeuds du graphe
  #
  # @return [Graphe]
  #
  def initialize( type, noeuds )
    DBC.require( noeuds.class == Hash, "L'argument noeuds doit etre un Hash" )

    @type = type
    @noeuds = {}

    noeuds.each_pair do |id, noeud|
      val, voisins = noeud
      @noeuds[id] = type.new( id, val, self, voisins )
    end
  end

  # Reinitialise les marques des noeuds, par exemple, pour effectuer
  # un nouveau parcours.
  def reset_marques
    @noeuds.each_pair do |id, noeud|
      noeud.reset_marque
    end
  end

  #
  # Le noeud du graphe identifie par id
  #
  # @param [Symbol] id L'identifiant du noeud
  # @return [Noeud] Le noeud
  #
  def []( id )
    @noeuds[id]
  end
end


#
# Classe avec les operations de base communes aux deux sortes de
# noeud.
#
class Noeud
  #
  # @param [Symbol] id L'identifiant du noeud
  # @param [Fixnum] val La valeur associee au noeud
  # @param [Graphe] graphe Le graphe dont le noeud fait partie
  # @param [Array<Symbol>] voisins La liste des noeuds adjacents
  #
  def initialize( id, val, graphe, voisins )
    @id = id
    @val = val
    @graphe = graphe
    @voisins = voisins
  end

  # Ajoute un noeud a la liste des voisins.
  def <<( v )
    @voisins << v

    self
  end

  # Methode pour marquer le noeud.
  #
  # Est indiquee avec "!" car est a la fois une requete (retourne
  # l'ancienne marque) et une commande (pour marquer le noeud s'il ne
  # l'est pas deja). Inhabituelle, mais simplifie l'interface et
  # l'utilisation.
  #
  def marquer!
    fail "Doit etre defini dans la sous-classe"
  end

  # Operation pour resetter la marque du noeud.
  def reset_marque
    fail "Doit etre defini dans la sous-classe"
  end

  # Somme de la valeur du noeud et de la valeur de tous les noeuds
  # accessibles *a partir de ce noeud*.
  #
  # Pour assurer qu'un noeud n'est compte qu'une seule fois en cas de
  # cycle (direct ou indirect), il faut marquer le noeud comme ayant
  # ete visite lors du parcours du graphe et ne pas traiter le noeud
  # si deja marque.
  #
  def somme
    fail "Doit etre defini dans la sous-classe"
  end

  # Representation textuelle simple.
  def to_s
    "#<Noeud #@id @val [#{@voisins.map(&:inspect).join(', ')}]"
  end

  # Chaine indiquant simplement l'identifiant du noeud.
  def inspect
    "#@id"
  end
end


# Version de Noeud utilisable de facon sequentielle.
class NoeudSeq < Noeud
  def initialize( id, val, graphe, voisins )
    super
    @marque = false
  end

  def reset_marque
    @marque = false
  end

  def marquer!
    marque = @marque
    @marque = true

    marque
  end

  # Somme sequentielle.
  def somme
    if marquer!
      # Deja marque, donc on ne le visite pas.
      0
    else
      # Pas marque: on visite les voisins pour calculer leur somme, a
      # laquelle on ajoute la valeur du noeud courant.
      @voisins
        .map { |v| @graphe[v] }
        .map(&:somme)
        .reduce(@val, :+)
    end
  end
end

# Version de Noeud utilisable de facon parallele.
class NoeudPar < Noeud
  def initialize( id, val, graphe, voisins )
    super
    @marque = SVar.new(:mutable)
    @marque.value = false
  end

  # Indice pour optimisation possible: Double-check!
  def marquer!
    # A COMPLETER.
    marque = @marque.take
    @marque.mutate! { true }

    marque
  end

  def reset_marque
    # A COMPLETER.
    @marque.mutate! { false }
  end

  #
  # Version du calcul de la somme qui doit s'executer en parallele,
  # tout en ayant du code "simple" --- aussi simple que la version
  # sequentielle.
  #
  # Plus specifiquement, on parle ici de parallelisme *recursif*,
  # i.e., que ce sont les appels a somme (sur les voisins) qui doivent
  # s'executer en parallele, puisque c'est la que pourrait etre le
  # gros du travail (si le voisin n'est pas marque).
  #
  # Peut (devrait!) utiliser des constructions de PRuby!
  #
  def somme
    # A COMPLETER.
    if marquer!
      # Deja marque, donc on ne le visite pas.
      0
    else
      # Pas marque: on visite les voisins pour calculer leur somme, a
      # laquelle on ajoute la valeur du noeud courant.
      @voisins
        .pmap { |v| @graphe[v] }
        .pmap(&:somme)
        .reduce(@val, :+)
    end
  end
end
