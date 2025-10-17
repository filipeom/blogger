type t =
  { title : string option
  ; description : string option
  }
[@@deriving make, show]

let entity_name = "page"

let neutral = Ok (make ())

let validate_fields fields =
  let open Yocaml.Data.Validation in
  let+ title = optional fields "page_title" string
  and+ description = optional fields "description" string in
  make ?title ?description ()

let validate data = Yocaml.Data.Validation.record validate_fields data

let normalize page =
  Yocaml.Data.
    [ ("page_title", option string page.title)
    ; ("description", option string page.description)
    ]
