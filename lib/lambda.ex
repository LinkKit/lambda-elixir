defmodule Lambda do

end

defmodule Mix.Tasks.Lambda.Package do
  use Mix.Task
  use Mix.Config

  def run(args) do
    app = Mix.Project.config[:app]
    version = Mix.Project.config[:version]
    build_path = Mix.Project.config[:build_path]
    config = Mix.Config.read!(Mix.Project.config[:config_path])
    release_path = "#{build_path}/#{Mix.env}/rel/#{app}"
    deploy_path = "./deploy"

    Mix.shell.info "Building release"
    dockerCmd = "docker run --rm -v $PWD:/home -e MIX_ENV=#{Mix.env} linkkit/lambda-elixir-builder mix release --env=prod"
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
