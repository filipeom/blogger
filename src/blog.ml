open Yocaml

module Source = struct
  let source_root = Path.(rel [])

  let assets = Path.(source_root / "assets")

  let pages = Path.(source_root / "pages")

  let templates = Path.(source_root / "templates")

  let template path = Path.(templates / path)

  let as_html into file = Path.move ~into file |> Path.change_extension "html"
end

module Target = struct
  let target_root = Path.(rel [ "_build" ])

  let site = Path.(target_root / "_html")

  let cache = Path.(target_root / "cache")
end

let process_assets =
  Action.batch ~only:`Directories Source.assets
    (Action.copy_directory ~into:Target.site)

let process_page file =
  let target_file = Source.as_html Target.site file in
  let open Task in
  Action.Static.write_file_with_metadata target_file
    (Yocaml_yaml.Pipeline.read_file_with_metadata (module Archetype.Page) file
    >>> Yocaml_omd.content_to_html ()
    >>> Yocaml_jingoo.Pipeline.as_template
          (module Archetype.Page)
          (Source.template "page.html")
    >>> Yocaml_jingoo.Pipeline.as_template
          (module Archetype.Page)
          (Source.template "default.html"))

let process_pages =
  Action.batch ~only:`Files ~where:(Path.has_extension "md") Source.pages
    process_page

let process_all () =
  let open Eff in
  Action.restore_cache ~on:`Source Target.cache
  >>= process_assets >>= process_pages
  >>= Action.store_cache ~on:`Source Target.cache
