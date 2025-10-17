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
