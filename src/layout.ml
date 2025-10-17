open Yocaml

module Config = struct
  type author =
    { email : string option
    ; orcid : string option
    ; scholar : string option
    ; github : string option
    ; linkedin : string option
    }
  [@@deriving make, show]

  let validate_author =
    let open Yocaml.Data.Validation in
    record @@ fun fields ->
    let+ email = optional fields "email" string
    and+ orcid = optional fields "orcid" string
    and+ scholar = optional fields "scholar" string
    and+ github = optional fields "github" string
    and+ linkedin = optional fields "linkedin" string in
    make_author ?email ?orcid ?scholar ?github ?linkedin ()

  type t = { author : author } [@@deriving make, show]

  let entity_name = "Config"

  let neutral = Ok (make ~author:(make_author ()))

  let validate =
    let open Yocaml.Data.Validation in
    record @@ fun fields ->
    let+ author = required fields "author" validate_author in
    make ~author

  let normalize_author (author : author) =
    Data.
      [ ("email", option string author.email)
      ; ("orcid", option string author.orcid)
      ; ("scholar", option string author.scholar)
      ; ("github", option string author.github)
      ; ("linkedin", option string author.linkedin)
      ]

  let normalize config =
    Data.[ ("author", record @@ normalize_author config.author) ]
end

type t =
  { page : Page.t
  ; config : Config.t
  }
[@@deriving make, show]

let normalize layout =
  Page.normalize layout.page @ Config.normalize layout.config
