open Cmdliner

let run () = Blog.build ()

(* let cmd_serve = *)
(*   let term = *)
(*     let open Term.Syntax in *)
(*     let port = *)
(*       let doc = "Port to listen" in *)
(*       Arg.(value & opt int 8000 & info [ "port"; "p" ] ~doc) *)
(*     in *)
(*     let+ port = port in *)
(*     serve ~port *)
(*   in *)
(*   let info = *)
(*     let doc = "Serve website" in *)
(*     Cmd.info "serve" ~doc *)
(*   in *)
(*   Cmd.v info term *)

let cmd_run =
  let term = Term.(const run $ const ()) in
  let info =
    let doc = "Compile website" in
    Cmd.info "run" ~doc
  in
  Cmd.v info term

let cli =
  let name = "home" in
  let info = Cmdliner.Cmd.info name in
  Cmdliner.Cmd.group info [ cmd_run ]

let () =
  match Cmdliner.Cmd.eval_value' cli with `Ok () -> () | `Exit n -> exit n
