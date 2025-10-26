let parse lines =
  let open Result.Syntax in
  let in_metadata = ref false in
  let rec loop (meta, content) = function
    | [] -> (meta, content)
    | "---" :: remaining ->
      in_metadata := not !in_metadata;
      loop (meta, content) remaining
    | line :: remaining ->
      let acc =
        if !in_metadata then (line :: meta, content) else (meta, line :: content)
      in
      loop acc remaining
  in
  let lines = List.map String.trim lines in
  let meta, content = loop ([], []) lines in
  let* meta = String.concat "\n" @@ List.rev meta |> Yaml.of_string in
  let content = String.concat "\n" @@ List.rev content in
  Ok (meta, content)
