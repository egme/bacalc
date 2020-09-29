require "minitest/autorun"
require "../lib/processor.rb"

describe Processor do
  let(:header) { "playerID,yearID,teamID,AB,H" }
  let(:lines) { [] }
  let(:stats_file) { [header, *lines].join("\n") }
  let(:teams_file) { File.open("#{__dir__}/../data/Teams.csv", "r") }
  let(:year_filter) { nil }
  let(:team_filter) { nil }

  let(:result) do
    Processor.new(
      stats_file: stats_file,
      teams_file: teams_file,
      year_filter: year_filter,
      team_filter: team_filter
    ).sorted_stats
  end

  describe "simple processing" do
    let(:lines) { ["p1,2000,CLE,10,5"] }

    it "produces result" do
      assert_equal(1, result.length)
    end

    it "calculates and formats BA" do
      assert_equal(0.5, result.first.ba)
    end

    it "inflects team name" do
      assert_equal(["Cleveland Indians"], result.first.teams.to_a)
    end

    describe "with varying team name" do
      let(:lines) { ["p1,1901,CLE,10,5"] }

      it "fetches correct name" do
        assert_equal(["Cleveland Blues"], result.first.teams.to_a)
      end
    end

    describe "with unknown team" do
      let(:lines) { ["p1,2000,ZZZ,10,5"] }

      it "renders team name as N/A" do
        assert_equal(["N/A"], result.first.teams.to_a)
      end
    end

    describe "with several resulting rows" do
      let(:lines) do
        [
          "b,2000,ANA,10,2",
          "a,2000,ARI,10,3",
          "c,2000,ATL,10,1"
        ]
      end

      it "sorts them in descending BA order" do
        assert_equal(
          [["a", 0.3], ["b", 0.2], ["c", 0.1]],
          result.map { |r| [r.player, r.ba] }
        )
      end
    end
  end

  describe "with several stints in the season" do
    let(:lines) do
      [
        "p1,2000,ANA,10,5",
        "p1,2000,ARI,15,5",
        "p1,2000,ATL,20,5"
      ]
    end

    it "calculates average BA per season" do
      assert_in_delta(
        15.0 / (10 + 15 + 20),
        result.first.ba.to_f,
        0.001
      )
    end

    it "renders all team names comma-separated" do
      assert_equal(
        ["Anaheim Angels", "Arizona Diamondbacks", "Atlanta Braves"],
        result.first.teams.to_a
      )
    end
  end

  describe "with filters" do
    let(:lines) do
      [
        "p1,2001,ANA,10,1",
        "p1,2002,ARI,10,6",
        "p1,2003,ATL,10,7",

        "p2,2001,ANA,10,2",
        "p2,2002,ARI,10,5",
        "p2,2003,ATL,10,9",

        "p3,2001,ANA,10,3",
        "p3,2002,ARI,10,4",
        "p3,2003,ATL,10,8"
      ]
    end
    let(:summary) { result.map { |r| [r.player, r.ba] } }

    describe "with year_filter" do
      let(:year_filter) { "2001" }

      it "filters and sorts correctly" do
        assert_equal(
          [["p3", 0.3], ["p2", 0.2], ["p1", 0.1]],
          summary
        )
      end
    end

    describe "with team_filter" do
      let(:team_filter) { "Atlanta Braves" }

      it "filters and sorts correctly" do
        assert_equal(
          [["p2", 0.9], ["p3", 0.8], ["p1", 0.7]],
          summary
        )
      end
    end
  end
end
