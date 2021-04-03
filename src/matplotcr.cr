module Matplotcr
  extend self

  alias NumberArray = Array(Int32) | Array(Int64) | Array(Float32) | Array(Float64)
  alias Number = Int32 | Int64 | Float32 | Float64

  abstract class Plot
    abstract def render : String

    def convert_list(data : NumberArray) : String
      return data.map { |x| x.to_s }.join(",")
    end
  end

  class RCFont
    getter family, styles

    def initialize(@family : String, @styles : Array(String))
    end
  end

  class Figure
    @plots = Array(Array(Plot)).new
    @current_index = 0

    def initialize(@python : String = "/usr/local/bin/python3",
                   @font : RCFont = RCFont.new("sans-serif", ["Lucida Grande"]),
                   @latex : Bool = false,
                   @figsize : Tuple(Float64, Float64) | Nil = nil,
                   @grid : Tuple(Int32, Int32) = {1, 1})
      @plots.push(Array(Plot).new)
    end

    def add(plot : Plot)
      @plots[@current_index].push plot
    end

    def subplot
      @current_index += 1
      @plots.push(Array(Plot).new)
    end

    def save(destination : String, dpi : Int64 | Nil = nil)
      s = Array(String).new
      s.push "import matplotlib"
      s.push "matplotlib.use('Agg')"
      s.push "from matplotlib import rc"
      s.push "import matplotlib.pyplot as plt"
      s.push "from matplotlib.lines import Line2D"
      s.push "rc('font', **{'family': '#{@font.family}', 'serif': '#{@font.styles.to_s}'})"
      s.push "rc('text', usetex=#{@latex ? "True" : "False"})"
      fs = @figsize
      if fs.nil?
        s.push "fig = plt.figure()"
      else
        s.push "fig = plt.figure(figsize=(#{fs[0]},#{fs[1]}))"
      end
      (0...@plots.size).each { |n|
        s.push "plt.subplot(#{@grid[0]}, #{@grid[1]}, #{n + 1})"
        @plots[n].each { |plot|
          s.push plot.render
        }
      }
      if dpi.nil?
        s.push "plt.savefig('#{destination}', format='png', transparent=False)"
      else
        s.push "plt.savefig('#{destination}', format='png', transparent=False, dpi=#{dpi})"
      end
      # create temporary file for the script
      tempfile = File.tempfile("matplotcrystal", ".py")
      File.write(tempfile.path, s.join("\n"))
      system "#{@python} #{tempfile.path}"
    end

    def show : String
      tempfile = File.tempfile("matplotcr-plot-", ".png")
      save(tempfile.path)
      return File.read(tempfile.path)
    end
  end

  class Title < Plot
    def initialize(@text : String, @raw : Bool = true)
    end

    def render : String
      if @raw
        return "plt.title(r#{@text})"
      else
        return "plt.title(#{@text})"
      end
    end
  end

  class LinePlot < Plot
    def initialize(x : NumberArray, y : NumberArray, colour : String = "", linestyle : String = "")
      @x = x
      @y = y
      @colour = colour
      @linestyle = linestyle
    end

    def render : String
      args = Array(String).new
      if @colour != ""
        args.push "color='#{@colour}'"
      end
      if @linestyle != ""
        args.push "linestyle='#{@linestyle}'"
      end

      if !args.empty?
        return "plt.plot([#{convert_list(@x)}],[#{convert_list(@y)}], #{args.join(",")})"
      else
        return "plt.plot([#{convert_list(@x)}],[#{convert_list(@y)}])"
      end
    end
  end

  class ScatterPlot < Plot
    def initialize(@x : NumberArray, @y : NumberArray, @colour : String = "", @marker : String | Nil = nil)
    end

    def render : String
      args = Array(String).new
      if @colour != ""
        args.push "color='#{@colour}'"
      end
      marker = @marker
      if !marker.nil?
        args.push "marker='#{marker}'"
      end

      if !args.empty?
        return "plt.scatter([#{convert_list(@x)}],[#{convert_list(@y)}], #{args.join(",")})"
      else
        return "plt.scatter([#{convert_list(@x)}],[#{convert_list(@y)}])"
      end
    end
  end

  class Histogram < Plot
    def initialize(@x : NumberArray, @bins : Int32 = 20)
    end

    def render : String
      args = Array(String).new
      args.push "bins=#{@bins}"

      return "plt.hist([#{convert_list(@x)}], #{args.join(",")})"
    end
  end

  class Density < Plot
    def initialize(@x : NumberArray, @points : Int32 = 100, @colour : String = "", @linestyle : String | Nil = nil)
    end

    def render : String
      args = Array(String).new
      if @colour != ""
        args.push "color='#{@colour}'"
      end
      linestyle = @linestyle
      if !linestyle.nil?
        args.push "linestyle='#{@linestyle}'"
      end

      s = Array(String).new
      s.push("from scipy import stats")
      s.push("import numpy as np")
      s.push("_data = [#{convert_list(@x)}]")
      x_max = @x.max
      x_min = @x.min
      steps = ((x_max - x_min).abs).fdiv(@points)
      s.push("_density = stats.kde.gaussian_kde(_data)")
      s.push("_x = np.arange(#{x_min}, #{x_max}, #{steps})")

      if !args.empty?
        s.push("plt.plot(_x, _density(_x), #{args.join(",")})")
      else
        s.push("plt.plot(_x, _density(_x))")
      end

      return s.join("\n")
    end
  end

  class Line < Plot
    def initialize(@p0 : Tuple(Number, Number), @p1 : Tuple(Number, Number), @colour : String = "", @linestyle : String = "")
    end

    def render : String
      args = Array(String).new
      if @colour != ""
        args.push "color='#{@colour}'"
      end
      if @linestyle != ""
        args.push "linestyle='#{@linestyle}'"
      end

      if !args.empty?
        return "ax = plt.gca()\nax.add_line(Line2D([#{@p0[0]},#{@p1[0]}],[#{@p0[1]},#{@p1[1]}], #{args.join(",")}))"
      else
        return "ax = plt.gca()\nax.add_line(Line2D([#{@p0[0]},#{@p1[0]}],[#{@p0[1]},#{@p1[1]}]))"
      end
    end
  end

  class HorizontalLine < Plot
    def initialize(@y : Number, @colour : String = "", @linestyle : String = "")
    end

    def render : String
      args = Array(String).new
      if @colour != ""
        args.push "color='#{@colour}'"
      end
      if @linestyle != ""
        args.push "linestyle='#{@linestyle}'"
      end

      if !args.empty?
        return "plt.axhline(y=#{@y},#{args.join(",")})"
      else
        return "plt.axhline(y=#{@y})"
      end
    end
  end

  class VerticalLine < Plot
    def initialize(@x : Number, @colour : String = "", @linestyle : String = "")
    end

    def render : String
      args = Array(String).new
      if @colour != ""
        args.push "color='#{@colour}'"
      end
      if @linestyle != ""
        args.push "linestyle='#{@linestyle}'"
      end

      if !args.empty?
        return "plt.axvline(x=#{@x},#{args.join(",")})"
      else
        return "plt.axvline(y=#{@x})"
      end
    end
  end

  class Annotation < Plot
    def initialize(@x : Number, @y : Number, @text : String, @colour : String | Nil = nil)
    end

    def render : String
      colour = @colour
      args = Array(String).new
      if !colour.nil?
        args.push "color='#{colour}'"
      end

      if args.empty?
        return "ax=plt.gca()\nax.annotate('#{@text}', xy=(#{@x}, #{@y}))"
      else
        return "ax=plt.gca()\nax.annotate('#{@text}', xy=(#{@x}, #{@y}), #{args.join(",")})"
      end
    end
  end

  class XLimit < Plot
    def initialize(@min : Number, @max : Number)
    end

    def render : String
      return "ax=plt.gca()\nax.set_xlim([#{@min},#{@max}])"
    end
  end

  class YLimit < Plot
    def initialize(@min : Number, @max : Number)
    end

    def render : String
      return "ax=plt.gca()\nax.set_ylim([#{@min},#{@max}])"
    end
  end
end
