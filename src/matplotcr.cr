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
    @plots = Array(Plot).new

    def initialize(@python : String = "/usr/local/bin/python3", @font : RCFont = RCFont.new("sans-serif", ["Lucida Grande"]), @latex : Bool = false)
    end

    def add(plot : Plot)
      @plots.push plot
    end

    def render : String
      @plots.each { |plot|
        @script.push plot.render
      }
      return @script.join("\n")
    end

    def save(destination : String)
      s = Array(String).new
      s.push "import matplotlib"
      s.push "matplotlib.use('Agg')"
      s.push "from matplotlib import rc"
      s.push "import matplotlib.pyplot as plt"
      s.push "from matplotlib.lines import Line2D"
      s.push "rc('font', **{'family': '#{@font.family}', 'serif': '#{@font.styles.to_s}'})"
      s.push "rc('text', usetex=#{@latex ? "True" : "False"})"
      s.push "matplotlib.rcParams['text.latex.unicode']=True"
      @plots.each { |plot|
        s.push plot.render
      }
      s.push "plt.savefig('#{destination}', format='png', transparent=False)"
      puts s.join("\n")
      # create temporary file for the script
      tempfile = File.tempfile("matplotcrystal", ".py")
      File.write(tempfile.path, s.join("\n"))
      system "#{@python} #{tempfile.path}"
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
    def initialize(x : NumberArray, y : NumberArray, colour : String = "")
      @x = x
      @y = y
      @colour = colour
    end

    def render : String
      args = Array(String).new
      if @colour != ""
        args.push "color='#{@colour}'"
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
end
