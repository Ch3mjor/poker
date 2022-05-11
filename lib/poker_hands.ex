defmodule Poker do
  @moduledoc """
  Definition of constants to be used.
  """
  @ranks %{
    "2" => 2,
    "3" => 3,
    "4" => 4,
    "5" => 5,
    "6" => 6,
    "7" => 7,
    "8" => 8,
    "9" => 9,
    "A" => 14,
    "J" => 11,
    "K" => 13,
    "Q" => 12,
    "T" => 10
  }

  @ranking_map %{
    "01" => "high card",
    "02" => "one pair",
    "03" => "two pair",
    "04" => "three of a kind",
    "05" => "straight",
    "06" => "flush",
    "07" => "full house",
    "08" => "four of a kind",
    "09" => "straight flush"
  }

  def best_hands(hands) do
    hands
    |> Enum.group_by(&score_poker_hand(&1))
    |> Enum.sort_by(fn {score, _hands} -> score end, &>=/2)
    |> List.first()
    |> convert_game_result_to_string()
    |> format_output()
  end

  def score_poker_hand(cards) do
    cards = cards |> Enum.map(&reduce_to_suit_and_rank/1)

    cond do
      check_if_straight_flush(cards) -> {"09", straight_flush(cards)}
      check_if_four_of_a_kind?(cards) -> {"08", four_of_a_kind(cards)}
      check_if_full_house?(cards) -> {"07", full_house(cards)}
      check_if_flush?(cards) -> {"06", flush(cards)}
      check_if_straight?(cards) -> {"05", straight(cards)}
      check_if_three_of_a_kind?(cards) -> {"04", three_of_a_kind(cards)}
      check_if_two_pairs?(cards) -> {"03", two_pairs(cards)}
      check_if_one_pair?(cards) -> {"02", one_pair(cards)}
      true -> {"01", cards |> sort_by_rank() |> Enum.reverse()}
    end
    |> then(fn {score, cards} -> score <> order_ranks(cards) end)
  end

  def format_output(result) do
    cond do
      elem(result, 0) == "Tie" ->
        {elem(result, 0),
         elem(result, 1)
         |> elem(1)}

      true ->
        {elem(result, 0),
         elem(result, 1)
         |> elem(1)
         |> hd()}
    end
  end

  def convert_game_result_to_string(cards) do
    win =
      cond do
        cards
        |> elem(1)
        |> Enum.count() > 1 ->
          "Tie"

        true ->
          cards
          |> elem(0)
          |> String.slice(0..1)
          |> then(&Map.fetch(@ranking_map, &1))
          |> elem(1)
      end

    {win, cards}
  end

  def check_if_one_pair?(cards) do
    cards |> group_by_same_rank() |> with_count(2)
  end

  def one_pair(cards) do
    pair = cards |> group_by_same_rank() |> with_count(2) |> elem(1)
    other = cards |> Enum.reject(&Enum.member?(pair, &1)) |> sort_by_rank() |> Enum.reverse()
    pair ++ other
  end

  def check_if_two_pairs?(cards) do
    cards |> group_by_same_rank() |> filter_count(2) |> Enum.count() |> Kernel.==(2)
  end

  def two_pairs(cards) do
    pairs =
      cards
      |> group_by_same_rank()
      |> filter_count(2)
      |> Enum.map(&elem(&1, 1))
      |> List.flatten()
      |> sort_by_rank()
      |> Enum.reverse()

    other_cards = cards |> Enum.reject(&Enum.member?(pairs, &1))
    pairs ++ other_cards
  end

  def check_if_three_of_a_kind?(cards) do
    cards |> group_by_same_rank() |> with_count(3)
  end

  def three_of_a_kind(cards) do
    triple_deck = cards |> group_by_same_rank() |> with_count(3) |> elem(1) |> sort_by_rank()

    others =
      cards |> Enum.reject(&Enum.member?(triple_deck, &1)) |> sort_by_rank() |> Enum.reverse()

    triple_deck ++ others
  end

  def check_if_straight?(cards) do
    cards |> sort_by_rank() |> sequence_check?()
  end

  def straight(cards) do
    cards |> sort_by_rank()
  end

  def check_if_flush?(cards) do
    cards |> group_by_same_suit() |> Enum.count() |> Kernel.==(1)
  end

  def flush(cards) do
    cards |> sort_by_rank()
  end

  def check_if_full_house?(cards) do
    grouped_by_rank = cards |> group_by_same_rank()
    grouped_by_rank |> with_count(3) && grouped_by_rank |> with_count(2)
  end

  def full_house(cards) do
    grouped_by_rank = cards |> group_by_same_rank()
    triple_set = grouped_by_rank |> with_count(3) |> elem(1) |> sort_by_rank()
    pair = grouped_by_rank |> with_count(2) |> elem(1) |> sort_by_rank()
    triple_set ++ pair
  end

  def check_if_four_of_a_kind?(cards) do
    cards |> group_by_same_rank() |> with_count(4)
  end

  def four_of_a_kind(cards) do
    grouped_by_rank = cards |> group_by_same_rank()
    four_matches = grouped_by_rank |> with_count(4) |> elem(1) |> sort_by_rank()
    last_card = grouped_by_rank |> with_count(1) |> elem(1)
    four_matches ++ last_card
  end

  def check_if_straight_flush(cards) do
    sequence = cards |> sort_by_rank() |> sequence_check?()
    grouped_by_suit = cards |> group_by_same_suit() |> Enum.count() |> Kernel.==(1)
    sequence && grouped_by_suit
  end

  def straight_flush(cards) do
    cards |> sort_by_rank()
  end

  def order_ranks(cards) do
    cards
    |> Enum.map(fn {rank, _} -> rank end)
    |> Enum.map(&Integer.to_string/1)
    |> Enum.map(&String.pad_leading(&1, 2, "0"))
    |> Enum.join()
  end

  def reduce_to_suit_and_rank(cards) do
    # break down the cards passed into a tuple with rank & suit
    [rank, suit] = String.codepoints(cards)
    {@ranks[rank], suit}
  end

  def group_by_same_suit(cards), do: cards |> Enum.group_by(fn {_, suit} -> suit end)
  def group_by_same_rank(cards), do: cards |> Enum.group_by(fn {rank, _} -> rank end)
  def with_count(cards, n), do: cards |> Enum.find(fn {_, cards} -> length(cards) == n end)
  def sort_by_rank(cards), do: cards |> Enum.sort_by(fn {rank, _} -> rank end)
  def filter_count(cards, n), do: cards |> Enum.filter(fn {_, cards} -> length(cards) == n end)
  def sequence_check?([{rank, _} | tail]), do: sequence_check?(tail, rank)
  def sequence_check?([], _previous), do: true
  def sequence_check?([{rank, _} | _tail], previous) when previous + 1 != rank, do: false
  def sequence_check?([{rank, _} | tail], _previous), do: sequence_check?(tail, rank)
end
