defmodule Nebulex.Cache.Stats do
  @moduledoc false

  alias Nebulex.Adapter

  ## API

  @doc """
  Implementation for `c:Nebulex.Cache.stats/0`.
  """
  def stats(name) do
    Adapter.with_meta(name, & &1.stats(&2))
  end

  if Code.ensure_loaded?(:telemetry) do
    @doc """
    Implementation for `c:Nebulex.Cache.dispatch_stats/1`.
    """
    def dispatch_stats(name, opts \\ []) do
      Adapter.with_meta(name, fn adapter, meta ->
        if info = adapter.stats(meta) do
          :telemetry.execute(
            Keyword.get(opts, :event_prefix, [:nebulex, :cache]) ++ [:stats],
            info.measurements,
            Map.merge(info.metadata, opts[:metadata] || %{})
          )
        else
          :ok
        end
      end)
    end
  else
    @doc """
    Implementation for `c:Nebulex.Cache.dispatch_stats/1`.
    """
    def dispatch_stats(_name, _opts \\ []), do: :ok
  end
end
