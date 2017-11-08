require 'spec_helper'
require 'svar'
require 'bin/wavefront'

Thread.abort_on_exception = true

describe SVar::SVarWritable do
  context "bin/wavefront.rb execute via la methode wavefront" do
    let(:attendu_4) { [[1, 1, 1, 1], [1, 3, 5, 7], [1, 5, 13, 25], [1, 7, 25, 63]] }

    it "calcule wavefront(4) de facon sequentielle" do
      Wavefront.run(4, :seq).must_equal attendu_4
    end

    it "calcule wavefront(4) de facon parallele" do
      Wavefront.run(4, :par).must_equal attendu_4
    end

    it "produit le meme resultat en parallele pour n = 10" do
      Wavefront.run(10, :par).must_equal Wavefront.run(10, :seq)
    end
  end
end

