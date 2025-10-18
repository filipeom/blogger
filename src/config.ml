open Yocaml

module Author = struct
  type t =
    { email : string option
    ; orcid : string option
    ; scholar : string option
    ; github : string option
    ; linkedin : string option
    }
  [@@deriving make, show]

  let validate =
    let open Yocaml.Data.Validation in
    record @@ fun fields ->
    let+ email = optional fields "email" string
    and+ orcid = optional fields "orcid" string
    and+ scholar = optional fields "scholar" string
    and+ github = optional fields "github" string
    and+ linkedin = optional fields "linkedin" string in
    make ?email ?orcid ?scholar ?github ?linkedin ()
end

type t = { author : Author.t } [@@deriving make, show]

let entity_name = "Config"

let neutral = Ok (make ~author:(Author.make ()))

let validate =
  let open Yocaml.Data.Validation in
  record @@ fun fields ->
  let+ author = required fields "author" Author.validate in
  make ~author

let normalize_author (author : Author.t) =
  Data.
    [ ("email", option string author.email)
    ; ("orcid", option string author.orcid)
    ; ("scholar", option string author.scholar)
    ; ("github", option string author.github)
    ; ("linkedin", option string author.linkedin)
    ]

let normalize config =
  Data.[ ("author", record @@ normalize_author config.author) ]
