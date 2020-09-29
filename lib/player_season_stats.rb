class PlayerSeasonStats < Struct.new(:player, :year, :teams, :ab, :h)
  def ba
    return 0.0 if ab.zero?

    h.to_f / ab
  end

  def for_report
    [
      player,
      year,
      teams.to_a.join(", "),
      format("%<ba>.3f", ba: ba)
    ]
  end
end
