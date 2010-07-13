module Prince
  class Pdf
    attr_accessor :executable, :sources, :stylesheets, :input

    def initialize(options = {})
      @sources = options[:sources].to_a
      @stylesheets = options[:stylesheets].to_a
      @input = options[:input]
    end

    def executable
      @executable ||= `which prince`.chomp
    end

    def input
      @input ||= 'html'
    end

    def stylesheets
      @stylesheets ||= []
    end

    def sources
      @sources ||= []
    end

    def command
      command_string = Array.new
      command_string << self.executable
      command_string << "--input=#{self.input}"
      self.sources.each do |source|
        command_string << source
      end
      command_string << '-o -'
      command_string.join(' ')
    end
  end
end