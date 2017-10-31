require 'spec_helper'
require 'svar'
require 'bin/fibo'

Thread.abort_on_exception = true

describe SVar::SVarWritable do
  context "bin/fibo.rb execute via la methode fibo" do
    it "calcule le premier cas de base" do
      Fibonacci.fibo(0).must_equal 0
    end

    it "calcule le deuxieme cas de base" do
      Fibonacci.fibo(1).must_equal 1
    end

    it "calcule le premier cas recursif" do
      Fibonacci.fibo(2).must_equal 1
    end

    it "calcule fibo(13)" do
      Fibonacci.fibo(13).must_equal 233
    end
  end

  context "bin/fibo.rb execute comme programme" do
    it "calcule fibo(13)" do
      res = %x{ bin/fibo.rb 13 }.to_i

      res.must_equal 233
    end
  end
end
