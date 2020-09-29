require "csv"

class CsvParser
  class Error < StandardError; end

  def self.parse(**args, &block)
    new.parse(**args, &block)
  end

  def parse(file:, csv_options: {}, required_columns: [], &block)
    @csv = CSV.new(file, **csv_options)

    inflect_column_numbers(required_columns: required_columns)
    extract_data(&block)

    @data unless block_given?
  end

  private

  def inflect_column_numbers(required_columns:)
    header = @csv.shift

    @column_numbers =
      if required_columns.empty?
        header.each_with_index.map { |v, i| [v, i] }.to_h
      else
        required_columns.map do |col|
          raise Error, "Required header '#{col}' not found" unless header.include?(col)

          [col, header.find_index(col)]
        end.to_h
      end
  end

  def extract_data
    line = 1
    @data = []
    @csv.each do |row|
      line += 1

      entry = build_entry_from_row(row: row, line: line)

      if block_given?
        yield entry, line
      else
        @data << entry
      end
    end
  end

  def build_entry_from_row(row:, line:)
    @column_numbers.each_pair.map do |col, num|
      [
        col,
        row.fetch(num)
      ]
    rescue IndexError
      raise Error, "Column '#{col}' not found in row ##{line}"
    end.to_h
  end
end
