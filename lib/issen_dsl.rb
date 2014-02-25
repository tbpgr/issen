# encoding: utf-8
require 'issen_dsl_model'

module Issen
  class Dsl
    attr_accessor :issen

    # String Define
    [:output_dir].each do |f|
      define_method f do |value|
        eval "@issen.#{f.to_s} = '#{value}'", binding
      end
    end

    # Array/Hash/Boolean Define
    [].each do |f|
      define_method f do |value|
        eval "@issen.#{f.to_s} = #{value}", binding
      end
    end

    def initialize
      @issen = Issen::DslModel.new
      @issen.output_dir = 'args_value2'
    end
  end
end
