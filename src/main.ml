open Cmdliner

let binary = "filipeom"

let serve port =
  Yocaml_unix.serve ~level:`Info ~target:Blog.Target.site ~port Blog.process_all

let run () = Yocaml_unix.run ~level:`Debug Blog.process_all

let cmd_serve =
  let port =
    let doc = "Port to listen" in
    Arg.(value & opt int 8000 & info [ "port"; "p" ] ~doc)
  in
  let doc = "Serve website" in
  let info = Cmd.info "serve" ~doc in
  Cmd.v info Term.(const serve $ port)

let cmd_run =
  let doc = "Compile website" in
  let info = Cmd.info "run" ~doc in
  Cmd.v info Term.(const run $ const ())

let cli =
  let info = Cmdliner.Cmd.info binary in
  Cmdliner.Cmd.group info [ cmd_serve; cmd_run ]

let () =
  match Cmdliner.Cmd.eval_value' cli with `Ok () -> () | `Exit n -> exit n
