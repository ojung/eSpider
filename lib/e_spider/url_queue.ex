defmodule ESpider.URLQueue do
  @moduledoc """
  Supervisor that supervises an Agent holding the kafka offset.
  KafkaEx workers are supervised by KafkaEx.

  Producer:
  * `push_url/1`

  Consumers:
  * `read_url/0`
  * `read_urls/1`
  """

  @kafka_topic (if (Mix.env == :test) do UUID.uuid4() else "url_queue" end)
  @supervisor :url_queue_supervisor
  @consumer :url_queue_consumer
  @producer :url_queue_producer
  @agent_name :url_queue_agent
  @one_day_in_seconds 24 * 60 * 60
  @look_back_in_seconds 2 * @one_day_in_seconds

  alias Calendar.DateTime

  import Supervisor.Spec

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: @supervisor)
  end

  def init(:ok) do
    KafkaEx.create_worker(@consumer)
    KafkaEx.create_worker(@producer)
    child = [worker(Agent, [__MODULE__, :start_agent, [], [name: @agent_name]])]
    supervise(child, [strategy: :one_for_one])
  end

  def start_agent, do: [current: 0, max: get_latest_offset]

  def push_urls(urls) do
    urls |> Enum.each(&push_url/1)
  end

  def push_url(url) do
    Agent.update(@agent_name, fn([current: current, max: max] = state) ->
      if (not Enum.member?(existing, url)) do
        KafkaEx.produce(@kafka_topic, 0, url, worker_name: @producer)
        [current: current, max: max + 1]
      else
        state
      end
    end)
  end

  defp get_latest_offset do
    KafkaEx.latest_offset(@kafka_topic, 0) |> extract_offset
  end

  defp get_offset_by_time(time) do
    KafkaEx.offset(@kafka_topic, 0, time) |> extract_offset
  end

  defp existing do
    look_back = DateTime.now("NZ")
                |> DateTime.advance!(-(@look_back_in_seconds))
                |> DateTime.to_erl
    timed = get_offset_by_time(look_back)
    latest = get_latest_offset
    fetch_messages(timed, latest - timed)
  end

  defp extract_offset(:topic_not_found), do: 0
  defp extract_offset(response) do
    offsets = List.first(response).partition_offsets
    case offsets do
      [%{error_code: 0, offset: [], partition: 0}] -> 0
      [%{error_code: 0, offset: offsets, partition: 0}] -> List.first(offsets)
    end
  end

  def read_url do
    read_urls(1) |> List.first
  end

  def read_urls(num_urls) do
    Agent.get_and_update(@agent_name, fn([current: current, max: max]) ->
      items = fetch_messages(current, num_urls)
      {items, [current: get_new_offset(current, num_urls, max), max: max]}
    end)
  end

  defp get_new_offset(current, num_urls, max) do
    new_offset = current + num_urls
    if (new_offset >= max) do max else new_offset end
  end

  defp fetch_messages(offset, num_messages) do
    args = [offset: offset, worker_name: @consumer]
    KafkaEx.fetch(@kafka_topic, 0, args)
    |> extract_messages
    |> Enum.take(num_messages)
  end

  defp extract_messages(:topic_not_found), do: nil
  defp extract_messages(response) do
    case List.first(response).partitions |> List.first do
      %{error_code: 0, hw_mark_offset: _, last_offset: _, message_set: []} -> []
      %{error_code: 0, hw_mark_offset: _, last_offset: _, message_set: messages} ->
        messages |> pluck(:value)
    end
  end

  defp pluck(list, key), do: Enum.map(list, fn(element) -> element[key] end)
end
