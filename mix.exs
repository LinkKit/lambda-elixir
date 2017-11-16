defmodule Lambda.Mixfile do
  use Mix.Project

  def project do
    [app: app(),
     version: version(),
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  defp version, do: "0.0.1"

  defp app, do: :lambda

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [

    ]
  end
end
