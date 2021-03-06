defmodule PokerTest do
  use ExUnit.Case
  doctest Poker

  test "both hands with identical four of a kind, tie determined by kicker" do
    four_3s_and_2 = ~w(3S 3H 2S 3D 3C)
    four_3s_and_4 = ~w(3S 3H 4S 3D 3C)
    winning_hand = Poker.best_hands([four_3s_and_2, four_3s_and_4])
    assert winning_hand == {"four of a kind", four_3s_and_4}
  end

  test "highest rank hand wins" do
    high_of_10 = ~w(2S 4C 7S 9H TH)
    high_of_jack = ~w(3S 4S 5D 6H JH)
    winning_hand = Poker.best_hands([high_of_10, high_of_jack])
    assert winning_hand == {"high card", high_of_jack}
  end

  test "both hands have two pairs, highest ranked pair wins" do
    eights_and_twos = ~w(2S 8H 2D 8D 3H)
    fives_and_fours = ~w(4S 5H 4C 8S 5D)
    winning_hand = Poker.best_hands([eights_and_twos, fives_and_fours])
    assert winning_hand == {"two pair", eights_and_twos}
  end

  test "both hands have two pairs, with the same highest ranked pair, tie goes to low pair" do
    queens_and_twos = ~w(2S QS 2C QD JH)
    queens_and_jacks = ~w(JD QH JS 8D QC)
    winning_hand = Poker.best_hands([queens_and_twos, queens_and_jacks])
    assert winning_hand == {"two pair", queens_and_jacks}
  end

  test "both hands have two identically ranked pairs, tie goes to remaining card (kicker)" do
    queens_jacks_and_8 = ~w(JD QH JS 8D QC)
    queens_jacks_and_2 = ~w(JS QS JC 2D QD)
    winning_hand = Poker.best_hands([queens_jacks_and_8, queens_jacks_and_2])
    assert winning_hand == {"two pair", queens_jacks_and_8}
  end

  test "three of a kind beats two pair" do
    eights_and_twos = ~w(2S 8H 2H 8D JH)
    three_fours = ~w(4S 5H 4C 8S 4H)
    winning_hand = Poker.best_hands([eights_and_twos, three_fours])
    assert winning_hand == {"three of a kind", three_fours}
  end

  test "both hands have three of a kind, tie goes to highest ranked triplet" do
    three_twos = ~w(2S 2H 2C 8D JH)
    three_aces = ~w(4S AH AS 8C AD)
    winning_hand = Poker.best_hands([three_twos, three_aces])
    assert winning_hand == {"three of a kind", three_aces}
  end

  test "two players can have same three of a kind, ties go to highest remaining cards" do
    three_aces_7_high = ~w(4S AH AS 7C AD)
    three_aces_8_high = ~w(4S AH AS 8C AD)
    winning_hand = Poker.best_hands([three_aces_7_high, three_aces_8_high])
    assert winning_hand == {"three of a kind", three_aces_8_high}
  end

  test "a straight beats three of a kind" do
    three_fours = ~w(4S 5H 4C 8D 4H)
    straight = ~w(3S 4D 2S 6D 5C)
    winning_hand = Poker.best_hands([three_fours, straight])
    assert winning_hand == {"straight", straight}
  end

  test "both hands with a straight, tie goes to highest ranked card" do
    straight_to_8 = ~w(4S 6C 7S 8D 5H)
    straight_to_9 = ~w(5S 7H 8S 9D 6H)
    winning_hand = Poker.best_hands([straight_to_8, straight_to_9])
    assert winning_hand == {"straight", straight_to_9}
  end

  test "even though an ace is usually high, a 5-high straight is the lowest-scoring straight" do
    straight_to_6 = ~w(2H 3C 4D 5D 6H)
    straight_to_5 = ~w(4S AH 3S 2D 5H)
    winning_hand = Poker.best_hands([straight_to_6, straight_to_5])
    assert winning_hand == {"straight", straight_to_6}
  end

  test "both hands have a flush, tie goes to high card, down to the last one if necessary" do
    flush_to_9 = ~w(4H 7H 8H 9H 6H)
    flush_to_7 = ~w(2S 4S 5S 6S 7S)
    winning_hand = Poker.best_hands([flush_to_9, flush_to_7])
    assert winning_hand == {"flush", flush_to_9}

    flush_to_9_with_4_matches = ~w(3S 6S 7S 8S 9S)
    winning_hand = Poker.best_hands([flush_to_9, flush_to_9_with_4_matches])
    assert winning_hand == {"flush", flush_to_9}
  end

  test "full house beats a flush" do
    flush_to_8 = ~w(3H 6H 7H 8H 5H)
    full = ~w(4S 5H 4C 5D 4H)
    winning_hand = Poker.best_hands([flush_to_8, full])
    assert winning_hand == {"full house", full}
  end

  test "both hands have a full house, tie goes to highest-ranked triplet" do
    full_of_4_by_9 = ~w(4H 4S 4D 9S 9D)
    full_of_5_by_8 = ~w(5H 5S 5D 8S 8D)
    winning_hand = Poker.best_hands([full_of_4_by_9, full_of_5_by_8])
    assert winning_hand == {"full house", full_of_5_by_8}
  end

  test "one pair beats high card" do
    high_of_king = ~w(4S 5H 6C 8D KH)
    pair_of_4 = ~w(2S 4H 6S 4D JH)
    winning_hand = Poker.best_hands([high_of_king, pair_of_4])
    assert winning_hand == {"one pair", pair_of_4}
  end
end
