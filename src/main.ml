open Cmdliner

let cmd_run =
  let term = Term.(const Blog.build $ const ()) in
  let info =
    let doc = "Compile website" in
    Cmd.info "run" ~doc
  in
  Cmd.v info term

let cli =
  let name = "blogger" in
  let info = Cmdliner.Cmd.info name in
  Cmdliner.Cmd.group info [ cmd_run ]

let exitcode =
  match Cmdliner.Cmd.eval_value cli with
  | Ok (`Help | `Version) -> Cmd.Exit.ok
  | Ok (`Ok result) -> begin
    match result with
    | Ok () -> Cmd.Exit.ok
    | Error (`Msg e) ->
      Logs.debug (fun m -> m "%s" e);
      1
  end
  | Error e -> begin
    match e with
    | `Term -> Cmd.Exit.some_error
    | `Exn -> Cmd.Exit.internal_error
    | `Parse -> Cmd.Exit.cli_error
  end

let () = exit exitcode
