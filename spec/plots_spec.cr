require "./spec_helper"
require "gsl"

describe Matplotcr do
  describe "Line plot" do
    it "must produce a default line plot" do
      figure = Matplotcr::Figure.new
      x = [1, 2, 3, 4]
      y = [5.5, 7.6, 11.1, 6.5]
      lineplot = Matplotcr::LinePlot.new(x, y)
      lineplot2 = Matplotcr::ScatterPlot.new(x, y)
      figure.add lineplot
      figure.add lineplot2
      figure.save("docs/images/test.png")
    end
    it "must produce a line plot with colour" do
      figure = Matplotcr::Figure.new
      x = [1, 2, 3, 4]
      y = [5.5, 7.6, 11.1, 6.5]
      lineplot = Matplotcr::LinePlot.new(x, y, colour="red", linestyle="--")
      lineplot2 = Matplotcr::ScatterPlot.new(x, y, colour="green")
      figure.add lineplot
      figure.add lineplot2
      figure.save("docs/images/test_colour.png")
    end
    it "must produce a default histogram" do
      y = Statistics::Normal.sample(1000, 0.0, 2.0)
      figure = Matplotcr::Figure.new
      
      hist = Matplotcr::Histogram.new(y)
      figure.add hist
      figure.save("docs/images/hist_default.png")
    end
    it "must produce a histogram with custom bins" do
      y = Statistics::Normal.sample(1000, 0.0, 2.0)
      figure = Matplotcr::Figure.new
      
      hist = Matplotcr::Histogram.new(y, bins=200)
      figure.add hist
      figure.save("docs/images/hist_bins.png")
    end
    it "must produce a line segment with defaults" do
      x = (0...100).to_a
      y = x.map { |p| p**2 }
      figure = Matplotcr::Figure.new
      
      hist = Matplotcr::LinePlot.new(x, y)
      figure.add hist
      figure.add Matplotcr::Line.new({2.0, 4.0}, {70.0, 70.0**2})
      figure.save("docs/images/line_segment.png")
    end
        it "must produce a line segment with defaults" do
      x = (0...100).to_a
      y = x.map { |p| p**2 }
      figure = Matplotcr::Figure.new
      
      hist = Matplotcr::LinePlot.new(x, y, colour="black")
      figure.add hist
      figure.add Matplotcr::Line.new({2.0, 4.0}, {70.0, 70.0**2}, colour="red", linestyle="--")
      figure.save("docs/images/line_segment_colour.png")
    end

  end

end