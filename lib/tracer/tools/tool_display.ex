defmodule Tracer.Tool.Display do
  @moduledoc """
  Reports display type tracing
  """
  alias __MODULE__
  alias Tracer.{Probe, ProcessHelper}
  use Tracer.Tool

  defstruct []

  def init(opts) do
    init_state = init_tool(%Display{}, opts, [:match])

    case Keyword.get(opts, :match) do
      nil ->
        init_state

      matcher ->
        node = Keyword.get(opts, :node)

        process =
          init_state
          |> get_process()
          |> ProcessHelper.ensure_pid(node)

        all_child = ProcessHelper.find_all_children(process, node)
        type = Keyword.get(opts, :type, :call)

        probe =
          Probe.new(
            type: type,
            process: [process | all_child],
            match: matcher
          )

        set_probes(init_state, [probe])
    end
  end

  def handle_event(event, state) do
    report_event(state, event)
    state
  end
end
