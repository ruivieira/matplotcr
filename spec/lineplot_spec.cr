require "./spec_helper"

describe Matplotcr do
  describe "Line plot" do
    it "must produce a default line plot" do
      figure = Matplotcr::Figure.new
      lineplot = Matplotcr::LinePlot.new([1, 2, 3], [5.5, 7.6, 11.1])
      lineplot2 = Matplotcr::ScatterPlot.new([1.0, 2.0, 4.5], [1, 2, 3])
      figure.add lineplot
      figure.add lineplot2
      figure.save("test.png")
    end
end
end