#!/usr/bin/env ruby

#
# Exemple (simple et simplifie) illustrant l'utilisation de services
# Web a distance, ayant des temps d'acces possiblement tres longs,
# donc pour lesquels ont veut faire les appels de facon
# asynchrone.... sauf que l'API est synchrone :( Il faut donc
# introduire une forme de callback, ce qui peut se faire via des
# threads ordinaires... ou plus simplement a l'aide de variables
# synchronisees.
#

require_relative "../lib/svar"

Thread.abort_on_exception = true

module ServicesExternes
  # Methodes pour injection des dependances.  Cela permet de specifier
  # quels services externes doivent etre utilises pour les services
  # prix_et_qte_disponible et paiement_ok?.

  attr_accessor :services_externes

  # Nom plus court pour reduire la longueur des lignes de code dans
  # les exemples ci-bas.
  alias_method :externes, :services_externes
end

class TraiterRequeteSeq
  extend ServicesExternes

  #
  # Traite une requete pour un produit, via une serie d'appels
  # utilisant des services externes synchrones, dont les temps
  # d'execution peuvent etre tres longs.
  #
  # Retourne le numero du fournisseur qui vend le produit au prix le
  # plus bas -- tout en ayant en stock toute la quantite desiree --
  # ainsi que le prix du produit. Retourne aussi le numero de la
  # premiere agence de paiement qui a confirme que le montant pouvait
  # etre debourse par l'usager.
  #
  # @param [Fixnum] produit Le produit requis
  # @param [Fixnum] qte_desiree La quantite desiree du produit
  # @param [Fixnum] id_usager Le numero d'identification de l'usager
  #
  # @return [Array<Fixnum, Fixnum, Fixnum>]
  #
  # @ensure result[0] = numero du fournisseur avec le prix minimum
  # @ensure result[1] = prix minimum de ce fournisseur
  # @ensure result[2] = numero de l'agence de paiement ayant confirme en premier
  #
  # @note Le probleme avec la solution ci-bas est que les appels a
  #       prix_et_qte_disponible, qui peuvent etre longs, se font de
  #       facon sequentielle (bloquante).  Idem pour les appels a
  #       paiement_ok?  De plus, dans ce dernier cas, il suffit
  #       d'obtenir une reponse positive d'une des agences pour
  #       confirmer le paiement, donc il serait bien de pouvoir
  #       terminer la methode run *aussitot* qu'une confirmation est
  #       arrivee.
  #
  def self.run( produit, qte_desiree, id_usager )
    prix_qte, fournisseur = FOURNISSEURS
      .map { |k| externes.prix_et_qte_disponible( k, produit, qte_desiree ) }
      .select { |prix, qte| qte >= qte_desiree }
      .each_with_index.min_by { |x| x.first.first }

    agence = AGENCES.find do |a|
      externes.paiement_ok?(a, id_usager, prix_qte.first * prix_qte.last)
    end

    [fournisseur, prix_qte.first, agence]
  end
end


class TraiterRequeteThread
  extend ServicesExternes

  #
  # Version *parallele* de la methode de la classe precedente, mais
  # utilisant exclusivement des elements de base de Ruby, donc Thread,
  # Mutex et ConditionVariable.
  #
  # Rappel: On veut que l'acces aux agences de paiement se complete
  # aussitot que l'une d'entre elles repond positivement.
  #
  def self.run( produit, qte_desiree, id_usager )
    # A COMPLETER.
    mutex = Mutex.new
    is_assign = ConditionVariable.new
    prix_qte, fournisseur, agence = nil, nil, nil
    th1 = Thread.new do
      mutex.synchronize do
        prix_qte, fournisseur = FOURNISSEURS
         .map { |k| externes.prix_et_qte_disponible( k, produit, qte_desiree ) }
         .select { |prix, qte| qte >= qte_desiree }
         .each_with_index.min_by { |x| x.first.first }
        is_assign.signal
      end
    end
    th2 = Thread.new do
      mutex.synchronize do
        is_assign.wait(mutex) while prix_qte == nil
        agence = AGENCES.find do |a|
          externes.paiement_ok?(a, id_usager, prix_qte.first * prix_qte.last)
        end
      end
    end
    th1.join
    th2.join
    [fournisseur, prix_qte.first, agence]
  end
end


class TraiterRequeteSVar
  extend ServicesExternes

  #
  # Version *parallele* de la methode des classes precedentes, mais
  # utilisant des SVar.
  #
  # Rappel: On veut que l'acces aux agences de paiement se complete
  # aussitot que l'une d'entre elles repond positivement.
  #
  def self.run( produit, qte_desiree, id_usager )
    sv = SVar.new do
      FOURNISSEURS
      .map { |k| externes.prix_et_qte_disponible( k, produit, qte_desiree ) }
      .select { |prix, qte| qte >= qte_desiree }
      .each_with_index.min_by { |x| x.first.first }
    end
    agence = SVar.new do
      AGENCES.find do |a|
        externes.paiement_ok?( a,
                               id_usager,
                               sv.value.first.first * sv.value.first.last)
      end
    end

    [sv.value.last, sv.value.first.first, agence.value]
  end
end
