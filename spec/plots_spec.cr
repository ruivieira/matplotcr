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
    it "must produce a line plot with custom markers" do
      figure = Matplotcr::Figure.new
      x = [1, 2, 3, 4]
      y = [5.5, 7.6, 11.1, 6.5]
      lineplot = Matplotcr::LinePlot.new(x, y, colour="red", linestyle="--")
      lineplot2 = Matplotcr::ScatterPlot.new(x, y, colour="green", marker="*")
      figure.add lineplot
      figure.add lineplot2
      figure.save("docs/images/marker.png")
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
    it "must produce a plot with a different font" do
      font = Matplotcr::RCFont.new "monospace", ["Courier New"]
      figure = Matplotcr::Figure.new font: font
      x = [1, 2, 3, 4]
      y = [5.5, 7.6, 11.1, 6.5]
      lineplot = Matplotcr::LinePlot.new(x, y)
      lineplot2 = Matplotcr::ScatterPlot.new(x, y)
      figure.add lineplot
      figure.add lineplot2
    end
    it "must produce a plot with a title" do
      font = Matplotcr::RCFont.new "monospace", ["Courier New"]
      figure = Matplotcr::Figure.new font: font
      x = (0...1000).to_a
      y = x.map { |n| Math.sin(n / 50.0) }
      lineplot = Matplotcr::LinePlot.new(x, y, colour: "red")
      title = Matplotcr::Title.new %q("A plot with a title (in Courier New).")
      figure.add lineplot
      figure.add title
      figure.save("docs/images/plot_title.png")
    end
    it "must produce vertical and horizontal lines" do
      figure = Matplotcr::Figure.new
      x = (0...1000).to_a
      y = x.map { |n| Math.sin(n / 50.0) }
      lineplot = Matplotcr::LinePlot.new(x, y, colour: "red")
      figure.add lineplot
      figure.add Matplotcr::HorizontalLine.new y: 0 , colour: "black", linestyle: "--"
      (1..6).each { |i| figure.add Matplotcr::VerticalLine.new x: Math::PI * i * 50.0, colour: "blue", linestyle: "-."}
      figure.save("docs/images/plot_hv_lines.png")
    end
    it "must produce an annotation" do
      figure = Matplotcr::Figure.new latex: true
      x = [1, 2, 3, 4]
      y = [5.5, 7.6, 11.1, 6.5]
      lineplot = Matplotcr::ScatterPlot.new(x, y)
      figure.add lineplot
      points = x.zip(y).map { |a,b| [a, b]}
      (0...2).each { |i| figure.add Matplotcr::Annotation.new points[i][0] + 0.1, points[i][1] + 0.1, "$p_#{i}$" }
      figure.save("docs/images/annotation.png")
    end
    it "must produce a plot with custom size" do
      figure = Matplotcr::Figure.new(figsize: {20.0, 2.0})
      x = (0...1000).to_a
      y = x.map { |n| Math.sin(n / 50.0) }
      lineplot = Matplotcr::LinePlot.new(x, y, colour: "red")
      figure.add lineplot
      figure.add Matplotcr::HorizontalLine.new y: 0 , colour: "black", linestyle: "--"
      (1..6).each { |i| figure.add Matplotcr::VerticalLine.new x: Math::PI * i * 50.0, colour: "blue", linestyle: "-."}
      figure.save("docs/images/custom_size.png", dpi: 180)
    end
    it "must produce side-by-side plots" do
      figure = Matplotcr::Figure.new figsize: {8.0, 4.0}, grid: {1, 2}
      x = (0...1000).to_a
      y = x.map { |n| Math.sin(n / 50.0) }
      lineplot = Matplotcr::LinePlot.new(x, y, colour: "red")
      figure.add lineplot
      figure.add Matplotcr::HorizontalLine.new y: 0 , colour: "black", linestyle: "--"
      (1..6).each { |i| figure.add Matplotcr::VerticalLine.new x: Math::PI * i * 50.0, colour: "blue", linestyle: "-."}
      figure.subplot()
      x = [1, 2, 3, 4]
      y = [5.5, 7.6, 11.1, 6.5]
      lineplot = Matplotcr::LinePlot.new(x, y)
      lineplot2 = Matplotcr::ScatterPlot.new(x, y)
      figure.add lineplot
      figure.add lineplot2
      figure.save("docs/images/side_by_side.png")
    end
    it "must produce a simple grid" do
      x = (0...300).to_a
      figure = Matplotcr::Figure.new figsize: {8.0, 4.0}, grid: {3, 3}
      (0...9).each { |n|
        if n > 0
          figure.subplot
        end
        figure.add Matplotcr::LinePlot.new(x, x.map { |i| Math.sin n.to_f * i}, colour: "red")
      }
      figure.save("docs/images/grid.png")
    end
    it "must produce valid x and y limits" do
      x = Statistics::Normal.sample(1000, 0.0, 2.0)
      y = Statistics::Normal.sample(1000, 0.0, 2.0)
      figure = Matplotcr::Figure.new figsize: {8.0, 4.0}, grid: {1, 2}
      figure.add Matplotcr::XLimit.new 0.0, 1.0
      figure.add Matplotcr::ScatterPlot.new x, y
      figure.subplot
      figure.add Matplotcr::YLimit.new -1.0, 0.0
      figure.add Matplotcr::ScatterPlot.new x, y
      figure.save("docs/images/limits.png")
    end
  end

end