$:.unshift File.dirname(__FILE__)

class Object
  def blank?
    respond_to?(:empty?) ? empty? : !self
  end

  def present?
    !blank?
  end
end

class Prince
  attr_accessor :executable, :sources, :stylesheets, :input

  class SourceError < ArgumentError; end
  class InputError < ArgumentError; end

  def initialize(options = {})
    @sources = normalize_array_attribute(options[:sources])
    @stylesheets = normalize_array_attribute(options[:stylesheets])
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

  def stylesheets=(value)
    @stylesheets = normalize_array_attribute(value)
  end

  def sources
    @sources ||= []
  end

  def sources=(value)
    @sources = normalize_array_attribute(value)
  end
  alias_method :source=, :sources=

  def command
    validate_configuration!
    command_string = Array.new
    command_string << self.executable
    command_string << "--input=#{self.input}"
    self.sources.each do |source|
      command_string << source
    end
    command_string << '-o -'
    command_string.join(' ')
  end

  def to_stream
    pdf = IO.popen(self.command, "w+")
    pdf.close_write
    result = pdf.gets(nil)
    pdf.close_read
    return result
  end

  protected

  def validate_configuration!
    raise SourceError unless self.sources.present?
    raise InputError unless self.valid_inputs.include?(self.input)
  end

  def valid_inputs
    ['html', 'xml', 'auto']
  end

  def normalize_array_attribute(value)
    value.is_a?(Array) ? value : value.to_a
  end
end

