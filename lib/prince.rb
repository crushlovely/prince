$:.unshift File.dirname(__FILE__)
require 'extensions/object'

class Prince
  attr_accessor :executable, :stylesheets, :source, :input_format, :pdf, :output_file

  class ExecutableError < ArgumentError; end
  class SourceError < ArgumentError; end
  class InputError < ArgumentError; end
  class OutputFileError < ArgumentError; end

  def initialize(options = {})
    @stylesheets = normalize_array_attribute(options[:stylesheets])
    @source = options[:source]
    @input_format = options[:input_format]
  end

  def executable
    @executable ||= `which prince`.chomp
  end

  def input_format
    @input_format ||= 'html'
  end

  def stylesheets
    @stylesheets ||= []
  end

  def stylesheets=(value)
    @stylesheets = normalize_array_attribute(value)
  end
  alias_method :stylesheet=, :stylesheets=

  def command
    validate_configuration!
    command_string = Array.new
    command_string << self.executable
    command_string << "--input=#{self.input_format}"
    command_string << "--silent"
    self.stylesheets.each do |stylesheet|
      command_string << "--style=#{stylesheet}"
    end
    command_string << '-'
    command_string << '-o'

    if self.to_file?
      command_string << self.output_file
    else
      command_string << '-'
    end

    command_string.join(' ')
  end

  def to_pdf
    self.run_command
  end

  def to_file?
    self.output_file.present?
  end

  protected

  def run_command
    self.pdf = IO.popen(self.command, "w+")
    self.pdf.puts(self.source)
    if self.to_file?
      self.pdf.close
    else
      self.pdf.close_write
      result = self.pdf.gets(nil)
      self.pdf.close_read
      result
    end
  end

  def validate_configuration!
    raise ExecutableError unless self.executable.present?
    raise SourceError unless self.source.present?
    raise InputError unless self.valid_input_formats.include?(self.input_format)
  end

  def valid_input_formats
    ['html', 'xml', 'auto']
  end

  def normalize_array_attribute(value)
    value.is_a?(Array) ? value : value.to_a
  end
end

# prince = Prince.new
# prince.stylesheets = ['prince.css']
# prince.source = string
# prince.to_file('my.pdf')
# prince.to_stream