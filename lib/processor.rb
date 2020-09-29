require "set"

require "#{__dir__}/csv_parser.rb"
require "#{__dir__}/player_season_stats.rb"

class Processor
  UNKNOWN_TEAM = "N/A".freeze

  attr_reader :stats_file, :teams_file, :year_filter, :team_filter, :rows

  def initialize(stats_file:, teams_file:, year_filter: nil, team_filter: nil)
    @stats_file = stats_file
    @teams_file = teams_file
    @year_filter = year_filter
    @team_filter = team_filter
    @rows = {}
    @teams = nil
    @processed = false
  end

  def sorted_stats
    extract_rows! unless @processed

    @rows.values.sort_by { |el| -el.ba }
  end

  private

  def extract_rows!
    CsvParser.parse(
      file: stats_file,
      required_columns: %w[playerID yearID teamID AB H]
    ) do |entry|
      process_entry(entry: entry)
    end

    @processed = true
  end

  def teams
    return @teams unless @teams.nil?

    @teams = {}

    CsvParser.parse(
      file: teams_file,
      required_columns: %w[teamID name yearID]
    ) do |entry|
      @teams[[entry["teamID"], entry["yearID"]]] = entry["name"]
    end

    @teams
  end

  def filter_passed?(team:, year:)
    (team_filter.nil? || team_filter.empty? || team_filter == team) &&
      (year_filter.nil? || year_filter.empty? || year_filter == year)
  end

  def process_entry(entry:)
    team = teams.fetch([entry["teamID"], entry["yearID"]], UNKNOWN_TEAM)

    return unless filter_passed?(team: team, year: entry["yearID"])

    key = [entry["playerID"], entry["yearID"]]

    update_season_stats(key: key, team: team, entry: entry)
  end

  def prepare_season_stats(key:)
    @rows.fetch(
      key,
      PlayerSeasonStats.new(
        key[0],
        key[1],
        Set.new,
        0,
        0
      )
    )
  end

  def update_season_stats(key:, team:, entry:)
    row = prepare_season_stats(key: key)

    row.teams << team
    row.h += entry["H"].to_i
    row.ab += entry["AB"].to_i

    @rows[key] = row
  end
end
