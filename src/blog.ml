module Source = struct
  let source_root = Fpath.v "."

  let ( / ) = Fpath.( / )

  let assets = source_root / "assets"

  let pages = source_root / "pages"

  let templates = source_root / "templates"

  let config = source_root / "_config.yaml"

  let binary = Fpath.v Sys.argv.(0)

  let template path = templates / path

  let as_html into file =
    let base_name = Fpath.base file |> Fpath.set_ext ".html" in
    Fpath.(into // base_name)
end

module Target = struct
  let target_root = Fpath.v "_build"

  let ( / ) = Fpath.( / )

  let site = target_root / "_html"
end

let create_assets () =
  Path.iter ~traverse:`None ~elements:`Dirs Source.assets @@ fun dir ->
  match Fpath.rem_prefix Source.assets dir with
  | Some base_dir ->
    let new_dir = Fpath.(normalize (Target.site // base_dir)) in
    Logs.debug (fun m ->
      m "Copying assets: %a -> %a" Fpath.pp dir Fpath.pp new_dir );

    Path.create_dir new_dir;
    Path.copy_directory ~into:new_dir dir
  | None ->
    Logs.warn (fun m ->
      m "Could not determine base directory for asset: %a" Fpath.pp dir )

let process_markdown file =
  let open Result.Syntax in
  let* lines = Bos.OS.File.read_lines file in
  let* meta, content = Meta.parse lines in
  let doc = Cmarkit.Doc.of_string content in
  let html_content = Cmarkit_html.of_doc ~safe:false doc in
  let+ page_data = Page.of_yaml meta in
  (page_data, html_content)

let render_content page_data html_content =
  let open Jingoo_build.Types in
  let page_models = Page.models page_data in
  let models = ("content", string html_content) :: page_models in
  let template_file = Source.template (Page.get_template page_data) in
  Jingoo.Jg_template.from_file ~models (Fpath.to_string template_file)

let render_document config content page_data =
  let open Jingoo_build.Types in
  let page_models = Page.models page_data in
  let models =
    (("content", string content) :: Config.models config) @ page_models
  in
  let template_file = Source.template "document.html" in
  Jingoo.Jg_template.from_file ~models (Fpath.to_string template_file)

(* FIXME: Refactor, just a proof of concept *)
let create_page (config : Config.t) file =
  let open Result.Syntax in
  let target_file = Source.as_html Target.site file in
  Logs.debug (fun m -> m "creating page: %a" Fpath.pp target_file);
  let+ page_data, html_content = process_markdown file in
  let content = render_content page_data html_content in
  let document = render_document config content page_data in
  Path.write_file target_file document

let create_pages config =
  Path.iter ~traverse:`None ~elements:`Files Source.pages @@ fun file ->
  if Fpath.has_ext "md" file then create_page config file |> Utils.log_err

let init () =
  Logs.set_reporter (Logs_fmt.reporter ());
  Logs.set_level (Some Logs.Debug)

let build () =
  let open Result.Syntax in
  init ();
  let+ config = Config.from_file Source.config in
  Logs.debug (fun m -> m "using config:@; %a" Config.pp config);
  create_assets ();
  create_pages config
