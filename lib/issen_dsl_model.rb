# encoding: utf-8
require 'active_model'

module Issen
  class DslModel
    include ActiveModel::Model

    # output directory
    attr_accessor :output_dir
    validates :output_dir, presence: true

  end
end
