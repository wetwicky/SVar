require 'spec_helper'
require 'svar'
require 'bin/lazy_list'

Thread.abort_on_exception = true

def from( n )
  LazyList.cons( n ) { from(n+1) }
end

describe SVar do
  context "bin/lazy_list.rb utilise via ses methodes" do
    context "liste finie de deux elements" do
      let(:ll) { LazyList.cons(0) { LazyList.cons(1) } }
      it "retourne le 1er elements" do
        ll.head.must_equal 0
      end

      it "retourne le 2e elements" do
        ll.tail.head.must_equal 1
      end

      it "retourne nil sinon" do
        ll.tail.tail.must_be_nil
        ll.tail.tail.head.must_be_nil
      end

      it "retourne les divers prefixes" do
        ll.take(0).must_equal []
        ll.take(1).must_equal [0]
        ll.take(2).must_equal [0, 1]
        ll.take(3).must_equal [0, 1]
      end

      it "multiplie par 2 les elements pairs" do
        r = ll
          .filter(&:even?)
          .map { |x| 2 * x }
          .take(2)
          .must_equal [0]
      end
    end

    context "liste infinie de 1" do
      let(:uns) { LazyList.cons(1) { uns } }

      it "retourne 1 comme premier element" do
        uns.head.must_equal 1
      end

      it "retourne 1 comme deuxieme element" do
        uns.tail.head.must_equal 1
      end

      it "retourne 1 comme 101-ieme element" do
        uns.drop(100).head.must_equal 1
      end
    end

    context "liste infinie des entiers" do
      it "prend les 5 premiers entiers" do
        from(0).take(5).must_equal [0, 1, 2, 3, 4]
      end

      it "prend le 100-ieme et le 101-ieme entier" do
        from(0).drop(99).take(2).must_equal [99, 100]
      end

      it "produit les pairs a partir des ints" do
        from(0).map { |x| 2 * x }.drop(10).first.must_equal 20
      end

      it "filtre pour ne conserver que les pairs" do
        from(0).filter(&:even?).drop(10).first.must_equal 20
      end
    end
  end
end
