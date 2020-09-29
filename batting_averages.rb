require "./lib/csv_parser.rb"
# require "json"
require "set"
require "terminal-table"

teams = {}
CsvParser.parse(
  file: File.open("Teams.csv", "r"),
  required_columns: %w[teamID name yearID]
) do |entry|
  teams[[entry["teamID"], entry["yearID"]]] = entry["name"]
end

# ==============

year_filter = "1901"
# team_filter = "Cleveland Naps"

rows = {}

CsvParser.parse(
  file: File.open("Batting.csv", "r"),
  required_columns: %w[playerID yearID stint teamID AB H]
) do |entry|
  team = teams.fetch([entry["teamID"], entry["yearID"]], "N/A")

  next unless (!defined?(year_filter) || year_filter.empty? || year_filter == entry["yearID"]) &&
              (!defined?(team_filter) || team_filter.empty? || team_filter == team)

  key = [entry["playerID"], entry["yearID"]]
  row = rows.fetch(key, { team: Set.new, h: 0, ab: 0, ba: 0.0 })

  row[:team] << team
  row[:h] = row[:h] + entry["H"].to_i
  row[:ab] = row[:ab] + entry["AB"].to_i
  row[:ba] = row[:h].to_f / row[:ab] unless row[:ab].zero?

  rows[key] = row
end

rows =
  rows
  .to_a
  .sort_by { |el| -el[1][:ba] }
  .map do |el|
    [
      *el[0],
      el[1][:team].to_a.join(", "),
      format("%<ba>.3f", ba: el[1][:ba])
      # el[1][:ba].round(3)
    ]
  end

table = Terminal::Table.new(
  headings: ["Player ID", "Year", "Team name(s)", "Batting average"],
  rows: rows
)
table.align_column(3, :right)
puts table

# pp result
# pp teams&.first
