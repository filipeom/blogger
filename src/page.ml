module Base = struct
  type t =
    { page_title : string option
    ; description : string option
    }
  [@@deriving make, show, yaml ~skip_unknown]

  let models page =
    Jingoo_build.Types.
      [ ("page_title", option string page.page_title)
      ; ("description", option string page.description)
      ]
end

module Index = struct
  type t =
    { page_title : string option
    ; description : string option
    ; profile_photo : string option
    }
  [@@deriving make, show, yaml ~skip_unknown]

  let models page =
    Jingoo_build.Types.
      [ ("page_title", option string page.page_title)
      ; ("description", option string page.description)
      ; ("profile_photo", option string page.profile_photo)
      ]
end

type t =
  | Base of Base.t
  | Index of Index.t
[@@deriving show]

let of_yaml yaml =
  let open Result.Syntax in
  let* layout = Yaml.Util.find "layout" yaml in
  match layout with
  | None -> Error (`Msg "a page must define a layout")
  | Some (`String "base") ->
    let+ page = Base.of_yaml yaml in
    Base page
  | Some (`String "index") ->
    let+ page = Index.of_yaml yaml in
    Index page
  | Some unknown -> Error (`Msg (Fmt.str "unknown layout: %a" Yaml.pp unknown))

let get_template = function Base _ -> "base.html" | Index _ -> "index.html"

let models page =
  match page with
  | Base page -> Base.models page
  | Index page -> Index.models page
