require "minitest/autorun"
require "../lib/player_season_stats.rb"

describe PlayerSeasonStats do
  let(:ab) { 7 }
  let(:h) { 3 }
  let(:stats) do
    PlayerSeasonStats.new(
      "player",
      "1999",
      Set.new(["Team A", "Team B"]),
      ab,
      h
    )
  end

  describe "#ba" do
    it "correctly calculates BA" do
      assert_equal(
        (h.to_f / ab),
        stats.ba
      )
    end

    describe "when no hits" do
      let(:h) { 0 }

      it "returns zero" do
        assert_equal(0.0, stats.ba)
      end
    end
  end

  describe "#for_report" do
    it "returns valid array" do
      assert_equal(
        [
          "player",
          "1999",
          "Team A, Team B",
          (h.to_f / ab).round(3).to_s
        ],
        stats.for_report
      )
    end
  end
end
