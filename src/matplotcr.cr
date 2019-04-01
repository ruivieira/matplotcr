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

    def initialize(x : NumberArray, y : NumberArray)
        @x = x
        @y = y
    end

    def render: String
        return "plt.plot([#{convert_list(@x)}],[#{convert_list(@y)}])"
    end
end

class ScatterPlot < Plot
    def initialize(x : NumberArray, y : NumberArray)
        @x = x
        @y = y
    end

    def render : String
        return "plt.scatter([#{convert_list(@x)}],[#{convert_list(@y)}])"
    end
end

end