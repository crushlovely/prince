module Prince
  class Base
    attr_accessor :executable, :sources, :stylesheets, :input

    def initialize(options = {})
      @sources = options[:sources]
      @stylesheets = options[:stylesheets]
      @input = options[:input]
      normalize_sources_and_stylesheets
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

    private

    def normalize_sources_and_stylesheets
      @sources = @sources.to_a unless @sources.is_a?(Array)
      @stylesheets = @stylesheets.to_a unless @stylesheets.is_a?(Array)
    end
  end
end