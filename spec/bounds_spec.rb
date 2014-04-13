require_relative '../lib/bounds'

module Doge
  describe Bounds do
    it "should have correct dimensions" do
      bounds = Bounds.new(10, 20, 200, 300)
      expect(bounds.width).to eq 190
      expect(bounds.height).to eq 280
      expect(bounds.area).to eq 53200
    end

    describe "#contains" do
      it "should contain itself" do
        outer = Bounds.new(0, 0, 300, 300)
        inner = outer
        expect(outer.contains?(inner)).to be_true
      end

      it "should contain bounds inside it" do
        outer = Bounds.new(0, 0, 300, 300)
        inner = Bounds.new(20, 20, 100, 100)
        expect(outer.contains?(inner)).to be_true
        expect(inner.contains?(outer)).to be_false
      end

      it "should contain bounds with same edges as it" do
        outer = Bounds.new(0, 0, 300, 300)
        inner = Bounds.new(0, 0, 300, 100)
        expect(outer.contains?(inner)).to be_true
      end

      it "should not contain bounds partially outside of it" do
        outer = Bounds.new(0, 0, 300, 300)
        inner = Bounds.new(0, 0, 400, 100)
        expect(outer.contains?(inner)).to be_false
      end
    end

    describe "#split" do
      it "should split into 4 contained" do
        outer = Bounds.new(0, 0, 300, 300)
        inner = Bounds.new(20, 20, 100, 100)
        splits = outer.split(inner)
        expect(splits.length).to eq 4
        splits.each do |split|
          expect(outer.contains?(split)).to be_true
        end
      end

      it "should split into 3 contained" do
        outer = Bounds.new(0, 0, 300, 300)
        inner = Bounds.new(0, 20, 100, 100)
        splits = outer.split(inner)
        expect(splits.length).to eq 3
        splits.each do |split|
          expect(outer.contains?(split)).to be_true
        end
      end

      it "should split into 2 contained" do
        outer = Bounds.new(0, 0, 300, 300)
        inner = Bounds.new(0, 0, 100, 100)
        splits = outer.split(inner)
        expect(splits.length).to eq 2
        splits.each do |split|
          expect(outer.contains?(split)).to be_true
        end
      end

      it "should split into 1 contained" do
        outer = Bounds.new(0, 0, 300, 300)
        inner = Bounds.new(0, 0, 300, 100)
        splits = outer.split(inner)
        expect(splits.length).to eq 1
        splits.each do |split|
          expect(outer.contains?(split)).to be_true
        end
      end

      it "should split into none" do
        outer = Bounds.new(0, 0, 300, 300)
        inner = Bounds.new(600, 600, 620, 620)
        splits = outer.split(inner)
        expect(splits).to be_nil
      end
    end
  end
end
