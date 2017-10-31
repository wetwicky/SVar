require 'spec_helper'
require 'svar'

Thread.abort_on_exception = true

describe SVar::SVarWritable do
  describe "#then" do
    context SVar::SVar do
      it "recoit le resultat et le traite sans delai" do
        sv = SVar.new( :read_only, :async ) { 10 }
          .then { |x| x + 1 }
          .then { |y| 2 * y }

        v = nil
        lambda { v = sv.value }.wont_be_delayed
        v.must_equal 22
      end

      it "recoit le resultat et le traite avec delai" do
        sv = SVar.new( :read_only, :async ) { sleep DELAY / 2.0; 10 }
          .then { |x| x + 1 }
          .then { |y| sleep DELAY / 2.0; 2 * y }

        v = nil
        lambda { v = sv.value }.must_be_delayed(DELAY)
        v.must_equal 22
      end
    end

    context SVar::SVarWritable do
      it "recoit le resultat lorsqu'ecrit explicitement puis le traite" do
        sv = SVar.new
        sv2 = sv
          .then { |x| x + 1 }
          .then { |y| 2 * y }

        Thread.new{ sleep DELAY; sv.value = 10 }
        v = nil
        lambda { v = sv2.value }.must_be_delayed(DELAY)
        v.must_equal 22

        lambda { sv2.value }.wont_be_delayed
      end
    end
  end
end
