let ( let* ) = Result.bind

module Source = struct
  let source_root = Fpath.v "."

  let assets = Fpath.(source_root / "assets")

  let pages = Fpath.(source_root / "pages")

  let templates = Fpath.(source_root / "templates")

  let config = Fpath.(source_root / "_config.yaml")

  let binary = Fpath.v Sys.argv.(0)

  let template path = Fpath.(templates / path)

  let as_html into file =
    let base_name = Fpath.base file |> Fpath.set_ext ".html" in
    Fpath.(into // base_name)
end

module Target = struct
  let target_root = Fpath.(v "_build")

  let site = Fpath.(target_root / "_html")

  let cache = Fpath.(target_root / "cache")
end

let create_assets () =
  Path.iter ~traverse:`None ~elements:`Dirs Source.assets @@ fun dir ->
  let base_dir = Fpath.rem_prefix Source.assets dir |> Option.get in
  let new_dir = Fpath.(normalize (Target.site // base_dir)) in
  Logs.debug (fun m -> m "cp %a %a" Fpath.pp dir Fpath.pp new_dir);
  Path.create_dir new_dir;
  Path.copy_directory ~into:new_dir dir

let create_page (_config : Config.t) file =
  let target_file = Source.as_html Target.site file in
  Logs.debug (fun m -> m "creating page: %a" Fpath.pp target_file);
  let pipeline =
    let* content = Bos.OS.File.read file in
    let doc = Cmarkit.Doc.of_string content in
    let html = Cmarkit_html.of_doc ~safe:false doc in
    Bos.OS.File.write target_file html
  in
  (* let pipeline = *)
  (*   let open Task in *)
  (*   let+ () = Pipeline.track_file Source.binary *)
  (*   and+ config = *)
  (*     Yocaml_yaml.Pipeline.read_file_as_metadata (module Config) Source.config *)
  (*   and+ page, content = *)
  (*     Yocaml_yaml.Pipeline.read_file_with_metadata (module Page) file *)
  (*   and+ apply_templates = *)
  (*     Yocaml_jingoo.read_templates *)
  (*       [ Source.template template; Source.template "document.html" ] *)
  (*   in *)
  (*   let metadata = Document.make ~page ~config in *)
  (*   Logs.debug (fun m -> m "Using metadata: %a@." Document.pp metadata); *)
  (*   let content = Omd.of_string content |> Omd.to_html in *)
  (*   apply_templates (module Document) ~metadata content *)
  (* in *)
  (* Action.Static.write_file target_file pipeline *)
  pipeline |> Utils.log_err

let create_pages config =
  Path.iter ~traverse:`None ~elements:`Files Source.pages @@ fun file ->
  if Fpath.has_ext "md" file then create_page config file

let init () =
  Logs.set_reporter (Logs_fmt.reporter ());
  Logs.set_level (Some Logs.Debug)

let build () =
  init ();
  let config = Config.from_file Source.config |> Result.get_ok in
  Logs.debug (fun m -> m "using config:@; %a" Config.pp config);
  create_assets ();
  create_pages config
