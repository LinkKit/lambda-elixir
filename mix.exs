defmodule Lambda.Mixfile do
  use Mix.Project

  def project do
    [
      app: app(),
      version: version(),
      elixir: "~> 1.0",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "Lambda Shim",
      source_url: "https://github.com/linkkit/lambda-elixir"
    ]
  end

  defp version, do: "1.2.2"

  defp app, do: :lambda_shim

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [

    ]
  end

  defp description() do
    "Package Elixir for Lambda and run via shim"
  end

  defp package() do
    [
      # This option is only needed when you don't want to use the OTP application name
      name: "lambda_shim",
      # These are the default files included in the package
      files: ["lib", "priv", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Mick Hansen"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/linkkit/lambda-elixir"}
    ]
  end
end
