# encoding: utf-8
require 'issen_dsl'
require 'active_support/core_ext/object/inclusion'
require 'active_support/core_ext/string/starts_ends_with'

module Issen
  #  Issen Core
  class Core
    ISSEN_FILE = 'Issenfile'
    ISSEN_TEMPLATE = <<-EOS
# encoding: utf-8

# output directory
# output_dir is required
# output_dir allow only String
# output_dir's default value => "output directory name"
output_dir "output directory name"
    EOS

    # generate Issenfile to current directory.
    def init
      File.open(ISSEN_FILE, 'w') { |f|f.puts ISSEN_TEMPLATE }
    end

    # create dirs and files
    def execute(input)
      dsl = read_dsl
      output_dir = dsl.issen.output_dir
      create_root_dir(output_dir)
      headings = to_heading(input, output_dir)
    end

    private

    def read_dsl
      src = File.open(ISSEN_FILE) { |f|f.read }
      dsl = Issen::Dsl.new
      dsl.instance_eval src
      dsl
    end

    def create_root_dir(output_dir)
      Dir.mkdir(output_dir) unless Dir.exist? output_dir
    end

    def to_heading(input, output_dir)
      input_chars = input.chars
      level, word_ret, parent_dir, grand_parent_dir = 0, [], output_dir, output_dir
      input_chars.each_with_index do |char, index|
        key_word = char.in? %w(~ + -)
        if key_word
          word = word_ret.join
          word_dup = word.dup
          dir_file = create_file_dir(word, parent_dir)
          parent_dir, grand_parent_dir = get_grand_and_parent(parent_dir, grand_parent_dir, word_dup, word, level, char)
          word_ret = []
        else
          word_ret << char
        end
      end
      word = word_ret.join
      create_file_dir(word, parent_dir)
    end

    # rubocop:disable CyclomaticComplexity
    def get_grand_and_parent(parent_dir, grand_parent_dir, word_dup, word, level, char)
      level += char == '+' ? 0 : char == '~' ? 1 : -1
      case level
      when 0
        # not change
      when 1
        if is_dir?(word_dup)
          grand_parent_dir = parent_dir
          parent_dir = "#{parent_dir}/#{word}"
        end
      when -1
        parent_dir = grand_parent_dir
      end
      [parent_dir, grand_parent_dir]
    end
    # rubocop:enable CyclomaticComplexity

    def create_file_dir(word, parent_dir)
      is_dir = is_dir?(word)
      dir_file = dir_file_name(word, parent_dir)
      if is_dir
        Dir.mkdir(dir_file) unless Dir.exist? dir_file
      else
        File.open(dir_file, 'w:UTF-8') { |f|f.print '' } unless File.exist? dir_file
      end
      dir_file
    end

    def dir_file_name(word, parent_dir)
      word.gsub!(/^d_/, '')
      "#{parent_dir}/#{word}"
    end

    def is_dir?(word)
      word.starts_with?('d_')
    end

    def to_head(heading, head_char)
      heading.reduce([]) { |ret, value|ret << "#{head_char * value[:level]}#{value[:word]}" }.join("\n")
    end
  end
end
