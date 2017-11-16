defmodule Lambda do

end

defmodule Mix.Tasks.Lambda.Package do
  use Mix.Task
  use Mix.Config

  def run(args) do
    {opts, _args, _} = OptionParser.parse(args, switches: [umbrella: :boolean])

    umbrella = opts[:umbrella]
    app = Mix.Project.config[:app]
    app_path = File.cwd!
    #umbrella_path = args
    IO.puts Path.expand(Path.join(app_path, "../.."))

    version = Mix.Project.config[:version]
    build_path = Mix.Project.config[:build_path]
    release_path = "#{build_path}/#{Mix.env}/rel/#{app}"
    deploy_path = "./deploy"
    docker_home = if umbrella do Path.expand(Path.join(app_path, "../..")) else app_path end

    Mix.shell.info "Building release"
    dockerBase = "docker run --rm -v #{docker_home}:/home -e MIX_ENV=#{Mix.env} linkkit/lambda-elixir-builder"
    dockerCmd = if umbrella do "#{dockerBase} sh -c \"cd apps/#{app} && mix release --env=prod\"" else "#{dockerBase} mix release --env=prod" end
    IO.puts dockerCmd
    {dockerOut, dockerCode} = System.cmd("/bin/sh", ["-c", dockerCmd], env: [{"MIX_ENV", to_string(Mix.env)}])

    if (dockerCode != 0) do
      raise "error building release through docker #{dockerOut}"
    end

    File.mkdir_p!("#{deploy_path}/burn")
    System.cmd("tar", ["--directory=#{deploy_path}/burn", "-zxvf", "#{release_path}/releases/#{version}/#{app}.tar.gz"])

    #Mix.shell.info "Testing release: Starting and stopping app"
    #{startOut, startCode} = System.cmd("/bin/sh", ["-c", "#{release_path}/bin/#{app} start"])
    #:timer.sleep(1000)
    #{stopOut, stopCode} = System.cmd("/bin/sh", ["-c", "#{release_path}/bin/#{app} stop"])
    #if (startCode != 0 || stopCode != 0) do
    #  raise "error starting & stopping release #{startOut} #{stopOut}"
    #end

    Mix.shell.info "Generating index.js shim"
    index_template_path = Path.join(["#{:code.priv_dir(:lambda)}", "templates", "index.js.eex"])
    index_contents = EEx.eval_file(index_template_path, [
      app: app,
      http_shim_port: Application.get_env(app, :http_shim_port)
    ])
    File.write!(Path.join(deploy_path, "index.js"), index_contents)

    Mix.shell.info "Zipping"
    System.cmd("/bin/sh", ["-c", "cd #{deploy_path};zip -r #{app}_#{to_string(Mix.env)}.zip ."]);
  end

  def clean do
    File.rm_rf("./deploy")
  end
end
