defmodule Ecto.Query.Builder.Distinct do
  @moduledoc false

  alias Ecto.Query.Builder

  @doc """
  Escapes a list of quoted expressions.

  See `Ecto.BuilderUtil.escape/2`.

      iex> escape(quote do [x.x, foo()] end, [x: 0])
      {[{:{}, [], [{:{}, [], [:., [], [{:{}, [], [:&, [], [0]]}, :x]]}, [], []]},
        {:{}, [], [:foo, [], []]}],
       %{}}
  """
  @spec escape(Macro.t, Keyword.t) :: {Macro.t, %{}}
  def escape(expr, vars) do
    List.wrap(expr)
    |> Builder.escape(vars)
  end

  @doc """
  Builds a quoted expression.

  The quoted expression should evaluate to a query at runtime.
  If possible, it does all calculations at compile time to avoid
  runtime work.
  """
  @spec build(Macro.t, [Macro.t], Macro.t, Macro.Env.t) :: Macro.t
  def build(query, binding, expr, env) do
    binding          = Builder.escape_binding(binding)
    {expr, external} = escape(expr, binding)
    external         = Builder.escape_external(external)

    distinct = quote do: %Ecto.Query.QueryExpr{
                           expr: unquote(expr),
                           external: unquote(external),
                           file: unquote(env.file),
                           line: unquote(env.line)}
    Builder.apply_query(query, __MODULE__, [distinct], env)
  end

  @doc """
  The callback applied by `build/4` to build the query.
  """
  @spec apply(Ecto.Queryable.t, term) :: Ecto.Query.t
  def apply(query, expr) do
    query = Ecto.Queryable.to_query(query)
    %{query | distincts: query.distincts ++ [expr]}
  end
end
