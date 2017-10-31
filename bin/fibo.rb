#!/usr/bin/env ruby

#
# Programme pour calculer le N-ieme nombre de Fibonacci
#


require_relative "../lib/svar"

module Fibonacci
  Thread.abort_on_exception = true

  DEBUG = true && false # On met # devant && pour debogger.

  # Calcule le N-ieme nombre de Fibonacci avec du parallelisme a
  # granularite (tres) fine, en utilisant une approche avec
  # memorisation des appels deja calcules.
  #
  # C'est une forme de parallelisme de resultat: Un thread est
  # responsable de calculer une position du tableau qui contient les
  # resultats des appels pour fibo(i), pour i <= n.
  #
  # Le jiggle est utilise pour souligner que le resultat produit sera
  # correct peut importe la vitesse, donc l'ordre, dans lequel les
  # threads vont s'executer.
  #
  def self.fibo( n )
    return n if n == 0 || n == 1 # Cas de base trivial

    # Tableau pour memorisation des appels recursifs.
    sv = Array.new(n+1) { SVar.new }

    # Cas de base
    sv[0].value = 0
    sv[1].value = 1

    # Cas recursif paralleles -- a granularite (tres!) fine!
    (2..n).each do |i|
      Thread.new do
        jiggle
        sv[i].value = sv[i-1].value + sv[i-2].value
      end
    end

    sv[n].value
  end
end

if __FILE__ == $0
  ############################################################
  # Programme execute lorsque lance au niveau du shell.
  ############################################################
  n = ARGV.empty? ? 0 : ARGV.shift.to_i

  puts Fibonacci.fibo( n )
end

