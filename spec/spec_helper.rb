gem 'minitest'
require 'minitest/autorun'
require 'minitest/spec'

Thread.abort_on_exception = true

class Object
  #
  # Permet de sauter une suite de tests.
  #
  def _describe( test )
    puts "--- On saute les tests pour \"#{test}\" ---"
  end

  #
  # Permet de sauter un test.
  #
  def _it( test )
    puts "--- On saute le test \"#{test}\" ---"
  end

  #
  # Quelques alias pour donner un look encore plus comme RSpec.
  #
  alias :context :describe
  alias :_context :_describe
end

#################################################################
# Methodes auxiliaires.
#################################################################

MIN_DELAY = 0.05
DELAY = 0.4

class Proc
  DELAY_FRACTION = 0.75

  def must_be_delayed( delay = 1.0 )
    avant = Time.now
    call
    duree = Time.now - avant

    fail "*** must_be_delayed: expected delay = #{delay}; effective delay = #{duree}" if duree < DELAY_FRACTION * delay
  end

  def wont_be_delayed
    avant = Time.now
    call
    duree = Time.now - avant

    fail "*** wont_be_delayed: #{duree}" if duree > MIN_DELAY
  end
end
