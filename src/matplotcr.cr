module Matplotcr extend self

alias NumberArray = Array(Int32)|Array(Int64)|Array(Float32)|Array(Float64)

abstract class Plot
    abstract def render: String

    def convert_list(data : NumberArray) : String
        return data.map { |x| x.to_s }.join(",")
    end
end

class Figure
    @plots = Array(Plot).new

    def initialize(python : String = "/usr/local/bin/python3")
        @python = python
    end

    def add(plot : Plot)
        @plots.push plot
    end

    def render: String
        @plots.each { |plot|
            @script.push plot.render
        }
        return @script.join("\n")
    end

    def save(destination : String)
        s = Array(String).new
        s.push "import matplotlib"
        s.push "matplotlib.use('Agg')"
        s.push "import matplotlib.pyplot as plt"
        @plots.each { |plot|
            s.push plot.render
        }
        s.push "plt.savefig('#{destination}', format='png', transparent=False)"

        # create temporary file for the script
        tempfile = File.tempfile("matplotcrystal", ".py")
        File.write(tempfile.path, s.join("\n"))
        system "#{@python} #{tempfile.path}"
    end

end

class LinePlot < Plot

    def initialize(x : NumberArray, y : NumberArray, colour : String = "", linestyle : String = "")
        @x = x
        @y = y
        @colour = colour
        @linestyle = linestyle
    end

    def render: String

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

end