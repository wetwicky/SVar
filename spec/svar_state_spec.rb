require 'spec_helper'
require 'svar'

Thread.abort_on_exception = true

describe SVar::SVar do
  describe "#state et full?" do
    context :immediate do
      it "est :full des le depart" do
        sv = SVar.new( :read_only, :immediate ) { sleep DELAY; 10 }
        sv.state.must_equal :full
        assert sv.full?
      end
    end

    context :async do
      it "est initialement :in_evaluation" do
        sv = SVar.new( :read_only, :async ) { sleep DELAY; 10 }
        sv.state.must_equal :in_evaluation
      end

      it "devient :full lorsque disponible" do
        sv = SVar.new( :read_only, :async ) { 10 }
        sv.value
        sv.state.must_equal :full
        assert sv.full?
      end
    end

    context :frozen do
      it "est initialement :frozen" do
        sv = SVar.new( :read_only, :frozen ) { 10 }
        sv.state.must_equal :frozen
      end

      it "devient :in_evaluation lorsqu'on lance l'evaluation" do
        sv = SVar.new( :read_only, :frozen ) { sleep DELAY; 10 }
        sv.state.must_equal :frozen
        sv.eval
        sv.state.must_equal :in_evaluation
      end

      it "devient :full lorsque disponible" do
        sv = SVar.new( :read_only, :frozen ) { 10 }
        sv.value
        sv.state.must_equal :full
        assert sv.full?
      end
    end

    context :write_once do
      it "est initialement :empty si pas de bloc" do
        sv = SVar.new( :write_once )
        sv.state.must_equal :empty
      end

      it "est initialement :in_evaluation si bloc fournir et :async" do
        sv = SVar.new( :write_once ) { sleep DELAY; 10 }

        sv.state.must_equal :in_evaluation
      end

      it "devient :full lorsque value est definie" do
        sv = SVar.new( :write_once )
        sv.value = 10
        sv.state.must_equal :full
        sv.full?
      end
    end

    context :mutable do
      it "est initialement :empty" do
        sv = SVar.new( :mutable )
        sv.state.must_equal :empty
      end

      it "est initialement :in_evaluation si bloc fourni et :async" do
        sv = SVar.new( :mutable ) { sleep DELAY; 10 }

        sv.state.must_equal :in_evaluation
      end

      it "devient :full lorsque value est definie" do
        sv = SVar.new( :mutable )
        sv.value = 10
        sv.state.must_equal :full
        sv.full?
      end
    end
  end
end
