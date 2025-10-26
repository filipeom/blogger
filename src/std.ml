include Stdlib

module Result = struct
  include Result

  module Syntax = struct
    let ( let* ) = Result.bind

    let ( let+ ) v f = Result.map f v
  end
end
