require "minitest/autorun"
require "../lib/csv_parser.rb"

describe CsvParser do
  let(:file) { "a,b,c\n1,2,3\n4,5,6" }
  let(:csv_options) { {} }
  let(:required_columns) { [] }
  let(:block) { nil }

  def parse(&block)
    CsvParser.parse(
      file: file,
      csv_options: csv_options,
      required_columns: required_columns,
      &block
    )
  end

  describe "simple parsing" do
    it "parses rows to hashes" do
      assert_equal(
        [{ "a" => "1", "b" => "2", "c" => "3" }, { "a" => "4", "b" => "5", "c" => "6" }],
        parse
      )
    end
  end

  describe "with missing value" do
    let(:file) { "a,b,c\n1,2,3\n4,5" }

    it "raises an error" do
      e = assert_raises(CsvParser::Error) do
        parse
      end

      assert_equal "Column 'c' not found in row #3", e.message
    end
  end

  describe "with block passed" do
    let(:block) { proc { |el| el } }

    it "does not return data" do
      assert_nil(parse { nil })
    end

    it "passes each row hash into the block" do
      accum = []
      parse { |el| accum << el }
      assert_equal(
        [{ "a" => "1", "b" => "2", "c" => "3" }, { "a" => "4", "b" => "5", "c" => "6" }],
        accum
      )
    end
  end

  describe "with csv_options parameter" do
    let(:csv_options) { { skip_blanks: true, col_sep: "|" } }
    let(:file) { "a|b|c\n\n\n1|2|3\n\n\n4|5|6\n\n" }

    it "passes it down to CSV" do
      assert_equal(
        [{ "a" => "1", "b" => "2", "c" => "3" }, { "a" => "4", "b" => "5", "c" => "6" }],
        parse
      )
    end
  end

  describe "with required_columns" do
    let(:required_columns) { %w[a c] }

    it "extracts only them" do
      assert_equal(
        [{ "a" => "1", "c" => "3" }, { "a" => "4", "c" => "6" }],
        parse
      )
    end
  end

  describe "with missing required column" do
    let(:required_columns) { %w[a x] }

    it "raises an error" do
      e = assert_raises(CsvParser::Error) do
        parse
      end

      assert_equal "Required header 'x' not found", e.message
    end
  end
end
