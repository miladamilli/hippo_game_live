defmodule HippoGameLiveWeb.HippoGameLive do
  use Phoenix.LiveView

  def render(assigns) do
    HippoGameLiveWeb.HippoGameView.render("index.html", assigns)
  end

  @topic inspect(__MODULE__)

  @game_length 30
  def mount(session, socket) do
    socket =
      socket
      |> new_game()
      |> assign(best_score: String.to_integer(Map.get(session.cookies, "best_score", "0")))
      |> assign(scores: [])

    if connected?(socket) do
      Phoenix.PubSub.subscribe(HippoGameLive.PubSub, @topic)
      {:ok, schedule_tick(socket)}
    else
      {:ok, socket}
    end
  end

  defp new_game(socket) do
    assign(socket,
      board: map(),
      player_x: 1,
      player_y: 1,
      direction: :playerdown,
      score: 0,
      new_best_score?: false,
      bonus_value: 0,
      field_size: 50,
      start_time: System.os_time(:second),
      gameplay?: true,
      time_left: @game_length
    )
  end

  defp schedule_tick(socket) do
    Process.send_after(self(), :tick, 1000)
    socket
  end

  def handle_info(:tick, socket) do
    timeleft = socket.assigns.start_time + @game_length - System.os_time(:second)

    if timeleft <= 0 do
      %{score: score, best_score: best_score} = socket.assigns
      Phoenix.PubSub.broadcast(HippoGameLive.PubSub, @topic, {:score, score})
      new_best_score? = score > best_score
      best_score = if score > best_score, do: score, else: best_score

      {:noreply,
       assign(socket,
         gameplay?: false,
         best_score: best_score,
         time_left: 0,
         new_best_score?: new_best_score?
       )}
    else
      new_socket = schedule_tick(socket)
      {:noreply, assign(new_socket, board: add_new_bonus_field(socket), time_left: timeleft)}
    end
  end

  def handle_info({:score, score}, socket) do
    {:noreply, assign(socket, scores: Enum.take([score | socket.assigns.scores], 10))}
  end

  def handle_event("player", key, socket) when key in ["r", "R"] do
    if socket.assigns.gameplay? do
      {:noreply, socket}
    else
      {:noreply, schedule_tick(new_game(socket))}
    end
  end

  def handle_event("player", key, socket) do
    if socket.assigns.gameplay? do
      {:noreply, step(socket, key)}
    else
      {:noreply, socket}
    end
  end

  @board_size 10

  @bonus_frequency [1, 1, 1, 2, 2, 3, -1]
  defp map() do
    for x <- 1..@board_size, y <- 1..@board_size, into: %{} do
      [random] = Enum.take_random(@bonus_frequency ++ Enum.to_list(10..24), 1)
      type = create_new_bonus_field(random)
      {{x, y}, type}
    end
  end

  defp create_new_bonus_field(random) do
    case random do
      -1 -> :bonus_minus
      1 -> :bonus1
      2 -> :bonus2
      3 -> :bonus3
      _ -> :empty
    end
  end

  defp get_field_value(bonus) do
    case bonus do
      :bonus_minus -> -500
      :bonus1 -> 10
      :bonus2 -> 50
      :bonus3 -> 100
      :empty -> 0
    end
  end

  defp step(socket, step) do
    old_position = {socket.assigns.player_x, socket.assigns.player_y}
    {{x, y}, direction} = get_new_position(socket, step)

    new_score =
      Map.get(socket.assigns.board, {x, y})
      |> get_field_value()

    assign(socket,
      board: Map.put(socket.assigns.board, old_position, :empty),
      player_x: x,
      player_y: y,
      direction: direction,
      score: socket.assigns.score + new_score,
      bonus_value: new_score
    )
  end

  defp get_new_position(socket, step) do
    {x_old, y_old} = {socket.assigns.player_x, socket.assigns.player_y}
    old_direction = socket.assigns.direction

    {{x, y}, direction} =
      case step do
        "ArrowLeft" -> {{x_old - 1, y_old}, :playerleft}
        "ArrowRight" -> {{x_old + 1, y_old}, :playerright}
        "ArrowUp" -> {{x_old, y_old - 1}, :playerup}
        "ArrowDown" -> {{x_old, y_old + 1}, :playerdown}
        _ -> {{x_old, y_old}, old_direction}
      end

    {x, y} =
      if x in 1..@board_size and y in 1..@board_size do
        {x, y}
      else
        {x_old, y_old}
      end

    {{x, y}, direction}
  end

  defp add_new_bonus_field(socket) do
    board = socket.assigns.board
    {player_x, player_y} = {socket.assigns.player_x, socket.assigns.player_y}
    {x, y} = {:rand.uniform(@board_size), :rand.uniform(@board_size)}

    if Map.get(board, {x, y}) == :empty && x != player_x && y != player_y do
      [random] = Enum.take_random(@bonus_frequency, 1)
      Map.put(board, {x, y}, create_new_bonus_field(random))
    else
      add_new_bonus_field(socket)
    end
  end
end
