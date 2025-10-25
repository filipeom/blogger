let ( let* ) = Result.bind

type author =
  { email : string option
  ; orcid : string option
  ; scholar : string option
  ; github : string option
  ; linkedin : string option
  }
[@@deriving make, show, yaml]

let validate_author _data =
  (* let open Yocaml.Data.Validation in *)
  (* record @@ fun fields -> *)
  (* let+ email = optional fields "email" string *)
  (* and+ orcid = optional fields "orcid" string *)
  (* and+ scholar = optional fields "scholar" string *)
  (* and+ github = optional fields "github" string *)
  (* and+ linkedin = optional fields "linkedin" string in *)
  (* make ?email ?orcid ?scholar ?github ?linkedin () *)
  assert false

type t = { author : author } [@@deriving make, show, yaml]

let entity_name = "Config"

let neutral = Ok (make ~author:(make_author ()))

let validate _data =
  (* let open Yocaml.Data.Validation in *)
  (* record @@ fun fields -> *)
  (* let+ author = required fields "author" Author.validate in *)
  (* make ~author *)
  assert false

let normalize_author (_author : author) =
  (* Data. *)
  (*   [ ("email", option string author.email) *)
  (*   ; ("orcid", option string author.orcid) *)
  (*   ; ("scholar", option string author.scholar) *)
  (*   ; ("github", option string author.github) *)
  (*   ; ("linkedin", option string author.linkedin) *)
  (*   ] *)
  assert false

let normalize _config =
  (* Data.[ ("author", record @@ normalize_author config.author) ] *)
  assert false

let from_file file =
  let* content = Bos.OS.File.read file in
  let* yaml = Yaml.of_string content in
  of_yaml yaml
