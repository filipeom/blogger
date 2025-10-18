open Yocaml

module Source = struct
  let source_root = Path.rel []

  let assets = Path.(source_root / "assets")

  let pages = Path.(source_root / "pages")

  let templates = Path.(source_root / "templates")

  let config = Path.(source_root / "_config.yaml")

  let binary = Path.rel [ Sys.argv.(0) ]

  let template path = Path.(templates / path)

  let as_html into file = Path.move ~into file |> Path.change_extension "html"
end

module Target = struct
  let target_root = Path.(rel [ "_build" ])

  let site = Path.(target_root / "_html")

  let cache = Path.(target_root / "cache")
end

let create_assets =
  Action.batch ~only:`Directories Source.assets
    (Action.copy_directory ~into:Target.site)

let create_page ?(template = "base.html") file =
  let target_file = Source.as_html Target.site file in
  let pipeline =
    let open Task in
    let+ () = Pipeline.track_file Source.binary
    and+ config =
      Yocaml_yaml.Pipeline.read_file_as_metadata (module Config) Source.config
    and+ page, content =
      Yocaml_yaml.Pipeline.read_file_with_metadata (module Page) file
    and+ apply_templates =
      Yocaml_jingoo.read_templates
        [ Source.template template; Source.template "document.html" ]
    in
    let metadata = Document.make ~page ~config in
    Logs.debug (fun m -> m "Using metadata: %a@." Document.pp metadata);
    let content = Omd.of_string content |> Omd.to_html in
    apply_templates (module Document) ~metadata content
  in
  Action.Static.write_file target_file pipeline

let create_index =
  create_page ~template:"index.html" Path.(Source.pages / "index.md")

let create_pages =
  let where file =
    Path.has_extension "md" file && not (Path.basename file = Some "index.md")
  in
  Action.batch ~only:`Files ~where Source.pages
    (create_page ~template:"base.html")

let build () =
  let open Eff in
  Action.restore_cache Target.cache
  >>= create_assets >>= create_index >>= create_pages
  >>= Action.store_cache Target.cache
