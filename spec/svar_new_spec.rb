require 'spec_helper'
require 'svar'

Thread.abort_on_exception = true

describe SVar::SVar do
  describe ".new" do
    context "sans specification du type" do
      it "est equivalent a :write_once lorsque pas de bloc"  do
        sv = SVar.new

        assert sv.state == :empty
        assert sv.writable?

        refute sv.read_only?
        refute sv.mutable?
      end

      it "est equivalent a :write_once lorsqu'il y a un bloc"  do
        sv = SVar.new { sleep DELAY; 99 }

        assert sv.state == :in_evaluation
        assert sv.writable?

        refute sv.read_only?
        refute sv.mutable?
      end
    end

    context "avec specification de type" do
      context :read_only do
        context :immediate do
          it "est read_only? et deja full?" do
            sv = SVar.new( :read_only, :immediate ) { sleep DELAY; 99 }

            assert sv.read_only?
            assert sv.full?
          end
        end

        context :async do
          it "est read_only? et initialement :in_evaluation" do
            sv = SVar.new( :read_only, :async ) { sleep DELAY; 99 }

            assert sv.read_only?
            assert sv.state == :in_evaluation

            refute sv.empty?
            refute sv.full?
          end
        end

        context :frozen do
          it "est read_only? et dans l'etat :frozen" do
            sv = SVar.new( :read_only, :frozen ) { 99 }

            assert sv.read_only?
            assert sv.state == :frozen

            refute sv.empty?
            refute sv.full?
          end
        end
      end

      context :write_once do
        it "est writable? et empty? si pas de bloc" do
          sv = SVar.new( :write_once )

          assert sv.writable?
          assert sv.empty?

          refute sv.full?
        end

        it "est writable? et full? si bloc :immediate" do
          sv = SVar.new( :write_once, :immediate ) { 10 }

          assert sv.writable?
          assert sv.full?
        end

        it "est writable?, !empty? et !full? si bloc :frozen" do
          sv = SVar.new( :write_once, :frozen ) { 10 }

          assert sv.writable?
          refute sv.empty?
          refute sv.full?
        end
      end

      context :mutable do
        it "est mutable? et empty?" do
          sv = SVar.new( :mutable )

          assert sv.mutable?
          assert sv.empty?

          refute sv.full?
        end

        it "est mutable? et full? si bloc :immediate" do
          sv = SVar.new( :mutable, :immediate ) { 10 }

          assert sv.writable?
          assert sv.full?
        end

        it "est mutable?, !empty? et !full? si bloc :frozen" do
          sv = SVar.new( :mutable, :frozen ) { 10 }

          assert sv.mutable?
          refute sv.empty?
          refute sv.full?
        end
      end
    end
  end
end
