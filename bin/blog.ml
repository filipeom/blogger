open Yocaml

module Source = struct
  let source_root = Path.(rel [])

  let css = Path.(source_root / "css")

  let index = Path.(source_root / "index.md")

  let templates = Path.(source_root / "templates")

  let template path = Path.(templates / path)

  let as_html into file = Path.move ~into file |> Path.change_extension "html"
end

module Target = struct
  let target_root = Path.(rel [ "_build" ])

  let site = Path.(target_root / "_html")

  let cache = Path.(target_root / "cache")
end

let process_index =
  let index_target = Source.as_html Target.site Source.index in
  let open Task in
  Action.Static.write_file_with_metadata index_target
    (Yocaml_yaml.Pipeline.read_file_with_metadata
       (module Archetype.Page)
       Source.index
    >>> Yocaml_omd.content_to_html ()
    >>> Yocaml_jingoo.Pipeline.as_template
          (module Archetype.Page)
          (Source.template "index.html")
    >>> Yocaml_jingoo.Pipeline.as_template
          (module Archetype.Page)
          (Source.template "layout.html"))

let process_all () =
  let open Eff in
  Action.restore_cache ~on:`Source Target.cache
  >>= Action.copy_directory ~into:Target.site Source.css
  >>= process_index
  >>= Action.store_cache ~on:`Source Target.cache
