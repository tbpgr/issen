# encoding: utf-8
require 'spec_helper'
require 'issen_core'

describe Issen::Core do
  context :execute do
    TMP_ISSEN = 'tmp_issen'
    cases = [
      {
        case_no: 1,
        case_title: 'create dir case',
        issenfile: 'output_dir "./tmp"',
        output_dir: './tmp',
        input: 'd_hoge',
        expected_type: [:directory?],
        expected: ['./tmp/hoge']
      },
      {
        case_no: 2,
        case_title: 'create file case',
        issenfile: 'output_dir "./tmp"',
        output_dir: './tmp',
        input: 'hoge.txt',
        expected_type: [:file?],
        expected: ['./tmp/hoge.txt']
      },
      {
        case_no: 3,
        case_title: '+ case',
        issenfile: 'output_dir "./tmp"',
        output_dir: './tmp',
        input: 'd_hoge~hoge.txt',
        expected_type: [:directory?, :file?],
        expected: ['./tmp/hoge', './tmp/hoge/hoge.txt']
      },
      {
        case_no: 4,
        case_title: '+ case',
        issenfile: 'output_dir "./tmp"',
        output_dir: './tmp',
        input: 'd_hoge+hoge.txt',
        expected_type: [:directory?, :file?],
        expected: ['./tmp/hoge', './tmp/hoge.txt']
      },
      {
        case_no: 5,
        case_title: '^ case',
        issenfile: 'output_dir "./tmp"',
        output_dir: './tmp',
        input: 'd_hoge+d_hige~hige.txt-hoge.txt',
        expected_type: [:directory?, :directory?, :file?, :file?],
        expected: ['./tmp/hoge', './tmp/hige', './tmp/hige/hige.txt', './tmp/hoge.txt']
      }
    ]

    cases.each do |c|
      it "|case_no=#{c[:case_no]}|case_title=#{c[:case_title]}" do
        begin
          case_before c

          # -- given --
          issen_core = Issen::Core.new

          # -- when --
          issen_core.execute c[:input]
          actual = Dir.glob("#{c[:output_dir]}/**/*")

          # -- then --
          expect(actual.size).to eq(c[:expected].size)
          actual.each do |file|
            is_exists = c[:expected].include? file
            expect(is_exists).to be_true
            type = c[:expected_type][c[:expected].index(file)]
            is_correct_type = File.send(type, file)
            expect(is_correct_type).to be_true
          end
        ensure
          case_after c
        end
      end

      def case_before(c)
        Dir.mkdir(TMP_ISSEN) unless File.exist?(TMP_ISSEN)
        Dir.chdir(TMP_ISSEN)
        File.open(Issen::Core::ISSEN_FILE, 'w:UTF-8') { |f|f.print c[:issenfile] }
      end

      def case_after(c)
        Dir.chdir('../')
        return unless File.exist? TMP_ISSEN
        FileUtils.rm_rf("./#{TMP_ISSEN}")
      end
    end
  end
end
