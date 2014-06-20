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
      headings = create_files_and_dirs(input, output_dir)
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

    def create_files_and_dirs(input, output_dir)
      input_chars = input.chars
      level, word_ret, parent_dir, grand_parent_dir = 0, [], output_dir, output_dir
      input_chars.each do |char|
        word_ret, parent_dir = create_each_files_and_dirs(
              char, word_ret, parent_dir, grand_parent_dir, level)
      end
      create_file_dir(word_ret.join, parent_dir)
    end

    def operator?(char)
      char.in?(%w(~ + -))
    end

    def create_each_files_and_dirs(
      char, word_ret, parent_dir, grand_parent_dir, level)
      if operator?(char)
        word_ret, parent_dir = apply_operator(
          char, word_ret, parent_dir, grand_parent_dir, level)
      else
        word_ret << char
      end
      [word_ret, parent_dir]
    end

    def apply_operator(char, word_ret, parent_dir, grand_parent_dir, level)
      word = word_ret.join
      word_dup = word.dup
      dir_file, word = create_file_dir(word, parent_dir)
      parent_dir, grand_parent_dir = get_grand_and_parent(
        parent_dir, grand_parent_dir, word_dup, word, level, char)
      word_ret = []
      [word_ret, parent_dir]
    end

    # rubocop:disable CyclomaticComplexity, ParameterLists
    def get_grand_and_parent(parent_dir, grand_parent_dir, word_dup, word, level, char)
      level = move_level(char, level)
      case level
      when 0
        # not change
      when 1
        grand_parent_dir, parent_dir = shift_dirs(
          parent_dir, word, word_dup, grand_parent_dir)
      when -1
        parent_dir = grand_parent_dir
      end
      [parent_dir, grand_parent_dir]
    end
    # rubocop:enable CyclomaticComplexity, ParameterLists

    def move_level(char, level)
      case char
      when '+' then level + 0
      when '~' then level + 1
      else          level - 1
      end
    end

    def shift_dirs(parent_dir, word, word_dup, grand_parent_dir)
      if directory?(word_dup)
        [parent_dir, "#{parent_dir}/#{word}"]
      else
        [grand_parent_dir, parent_dir]
      end
    end

    def create_file_dir(word, parent_dir)
      is_directory = directory?(word)
      dir_file, word = dir_file_name(word, parent_dir)
      if is_directory
        Dir.mkdir(dir_file) unless Dir.exist? dir_file
      else
        File.open(dir_file, 'w:UTF-8') { |f|f.print '' } unless File.exist? dir_file
      end
      [dir_file, word]
    end

    def dir_file_name(word, parent_dir)
      word.gsub!(/^d_/, '')
      ["#{parent_dir}/#{word}", word]
    end

    def directory?(word)
      word.starts_with?('d_')
    end

    def to_head(heading, head_char)
      heading.reduce([]) { |a, e|a << "#{head_char * e[:level]}#{e[:word]}" }.join("\n")
    end
  end
end
