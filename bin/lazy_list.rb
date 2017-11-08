#!/usr/bin/env ruby

#
# Module pour definir des listes paresseuses.
#

require_relative "../lib/svar"

Thread.abort_on_exception = true

debug = true && false # On met # devant && pour debogger.

class LazyList
  include Enumerable

  def initialize( val )
    @head = val
    if block_given?
      @tail = SVar.new(:read_only, :frozen) { yield }
      @tail_evaluated = false
    else
      @tail = LazyListNil.send :new
      @tail_evaluated = true
    end
  end

  class << self
    alias_method :cons, :new
    private :new
  end

  def each
    pt = self
    until pt.nil?
      yield( pt.head )
      pt = pt.tail
    end
  end

  def nil?
    false
  end

  def head
    @head
  end

  def tail
    return @tail if @tail_evaluated

    @tail = @tail.value
    @tail_evaluated = true

    @tail
  end

  def drop( n )
    pt = self
    n.times do
      # Fonctionne toujours (meme si n > taille) a cause de LazyListNil.
      pt = pt.tail
    end

    pt
  end

  def map
    return self if self.nil?

    LazyList.cons( yield(head) ) { tail.map { |x| yield(x) } }
  end

  def filter
    pt = self
    pt = pt.tail until pt.nil? || yield(pt.head)

    return pt if pt.nil?

    LazyList.cons( pt.head ) { pt.tail.filter { |x| yield(x) } }
  end

  def to_s
    "#{@head} -> #{@tail}"
  end
end

class LazyListNil < LazyList
  def initialize; end

  def nil?; true end

  def head; nil end

  def tail; self end

  def to_s; "LazyListNil" end
end

if __FILE__ == $0
  ############################################################
  # Programme execute lorsque lance au niveau du shell.
  ############################################################
end

