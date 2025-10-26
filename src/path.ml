let create_dir path =
  let _ = Bos.OS.Dir.create path in
  ()

(** Iterate through a directory *)
let iter ?traverse ?elements path f =
  Bos.OS.Dir.fold_contents ?elements ?traverse (fun path () -> f path) () path
  |> Utils.log_err

(** Byte copy of a file *)
let copy_file src dst =
  let buff_size = 8192 in
  let buff = Bytes.create buff_size in
  In_channel.with_open_bin (Fpath.to_string src) @@ fun ic ->
  Out_channel.with_open_bin (Fpath.to_string dst) @@ fun oc ->
  let rec loop () =
    match In_channel.input ic buff 0 buff_size with
    | 0 -> ()
    | bytes_read ->
      Out_channel.output oc buff 0 bytes_read;
      loop ()
  in
  loop ()

let write_file path content = Bos.OS.File.write path content |> Utils.log_err

(** Moves the contents of a directory into another *)
let copy_directory ~into source =
  iter ~traverse:`None ~elements:`Files source @@ fun file ->
  let new_file = Fpath.(into / basename file) in
  Logs.debug (fun m -> m "mv %a %a" Fpath.pp file Fpath.pp new_file);
  copy_file file new_file
