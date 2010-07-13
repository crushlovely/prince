$:.unshift File.dirname(__FILE__)

class Object
  def blank?
    respond_to?(:empty?) ? empty? : !self
  end

  def present?
    !blank?
  end
end

require 'prince/base'

module Prince
  class ConfigurationError < StandardError; end
end