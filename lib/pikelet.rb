require "pikelet/version"
require "pikelet/file_definition"
require "pikelet/record_definition"
require "pikelet/field_definition"

module Pikelet
  def self.define(signature_field: nil, record_class: nil, &block)
    Pikelet::FileDefinition.new(signature_field: signature_field, record_class: record_class, &block)
  end
end
