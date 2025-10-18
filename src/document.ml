type t =
  { page : Page.t
  ; config : Config.t
  }
[@@deriving make, show]

let normalize layout =
  Page.normalize layout.page @ Config.normalize layout.config
