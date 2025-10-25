module Base = struct
  type t =
    { title : string option
    ; description : string option
    }
  [@@deriving make, show]

  let entity_name = "base"

  let neutral = Ok (make ())

  let validate_fields _fields =
    (* let open Yocaml.Data.Validation in *)
    (* let+ title = optional fields "page_title" string *)
    (* and+ description = optional fields "description" string in *)
    (* make ?title ?description () *)
    assert false

  let validate _data =
    (* Yocaml.Data.Validation.record validate_fields data *)
    assert false

  let normalize _page =
    (* Yocaml.Data. *)
    (* [ ("page_title", option string page.title) *)
    (* ; ("description", option string page.description) *)
    (* ] *)
    assert false
end

module Index = struct
  type t =
    { title : string option
    ; description : string option
    ; profile_photo : string option
    }
  [@@deriving make, show]

  let entity_name = "basex"

  let neutral = Ok (make ())

  let validate_fields _fields =
    (* let open Yocaml.Data.Validation in *)
    (* let+ title = optional fields "page_title" string *)
    (* and+ description = optional fields "description" string *)
    (* and+ profile_photo = optional fields "profile_photo" string in *)
    (* make ?title ?description ?profile_photo () *)
    assert false

  let validate _data =
    (* Yocaml.Data.Validation.record validate_fields data *)
    assert false

  let normalize _page =
    (* Yocaml.Data. *)
    (*   [ ("page_title", option string page.title) *)
    (*   ; ("description", option string page.description) *)
    (*   ; ("profile_photo", option string page.profile_photo) *)
    (*   ] *)
    assert false
end

type t =
  | Base of Base.t
  | Index of Index.t
[@@deriving show]

let entity_name = "page"

let validate _data =
  (* let open Yocaml.Data.Validation in *)
  (* record *)
  (*   (fun fields -> *)
  (*     let* layout = required fields "layout" string in *)
  (*     match layout with *)
  (*     | "index" -> *)
  (*       let+ page = Index.validate_fields fields in *)
  (*       Index page *)
  (*     | "base" -> *)
  (*       let+ page = Base.validate_fields fields in *)
  (*       Base page *)
  (*     | "article" -> assert false *)
  (*     | field -> Error (Yocaml.Nel.singleton (Missing_field { field })) ) *)
  (*   data *)
  assert false

let normalize = function
  | Base page -> Base.normalize page
  | Index page -> Index.normalize page
