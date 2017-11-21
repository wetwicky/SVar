#!/usr/bin/env ruby

#
# Programme pour remplir une matrice avec des dependances de style
# "wavefront" (semblables a celles pour le calcul de la distance
# d'edition), et ce avec du parallelisme a granularite (tres!) fine.
#
# Utilise du parallelisme de resultat: Un thread est responsable de
# calculer une et une seule position du tableau.  Les dependances sont
# satisfaites de facon implicite via l'utilisation de variables
# synchronisees.
#

require 'pruby'
require 'matrice'
require_relative "../lib/svar"

module Wavefront
  Thread.abort_on_exception = true

  DEBUG = true && false # On met # devant && pour debogger.

  #
  # Code sequentiel pour remplir la matrice.
  #
  def self.run_seq( n )
    m = Matrice.new( n, n )

    # Cas de base: 1ere ligne et 1ere colonne.
    (0...n).each do |k|
      m[k, 0] = 1
      m[0, k] = 1
    end

    # Cas recursifs.
    (1...n).each do |i|
      (1...n).each do |j|
        m[i, j] = m[i-1, j] + m[i-1, j-1] + m[i, j-1]
      end
    end

    m.to_a
  end

  #
  # Code parallele, a granularite tres fine, pour remplir la matrice.
  #
  # Les cases de la matrice ne sont pas de simples entiers, mais sont
  # plutot des SVar (:write_once).  En utilisant les methodes #value
  # et #value=, les boucles each peuvent (doivent!) donc etre
  # transformees en boucle completement paralleles de forme peach au
  # lieu de each.
  #
  def self.run_par( n )
    m = Matrice.new( n, n )

    # Cas de base: 1ere ligne et 1ere colonne.
    (0...n).peach do |k|
      m[k, 0] = SVar.new { 1 }
      m[0, k] = SVar.new { 1 }
    end
    (1...n).peach do |row|
      (1...n).peach do |col| #peach vs each ...
        # on retarde l'evaluation pour remplir la matrice avec des SVar
        m[row, col] = SVar.new(:write_once,:frozen) do
          m[row-1, col].value + m[row-1, col-1].value + m[row, col-1].value
        end
      end
    end
    # l'évaluation est lancé  en allant recupéré la valeur
    m.to_a.pmap { |row| row.pmap { |e| e.value } }
  end

  #
  # Dispatcher.
  #
  def self.run( n, methode = :seq )
    if methode == :seq
      run_seq( n )
    elsif methode == :par
      run_par( n )
    else
      DBC.assert false, "Cas impossible: methode = #{methode}"
    end
  end
end

if __FILE__ == $0
  ############################################################
  # Programme execute lorsque lance au niveau du shell.
  ############################################################
  n = ARGV.empty? ? 0 : ARGV.shift.to_i

  p Wavefront.run( n, :seq )
  p Wavefront.run( n, :par )
end
