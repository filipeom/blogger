open Yocaml

let create_assets =
  Action.batch ~only:`Directories Build.Source.assets
    (Action.copy_directory ~into:Build.Target.site)

let create_page =
  let config =
    Yocaml_yaml.Pipeline.read_file_as_metadata
      (module Layout.Config)
      Build.Source.config
  in
  fun file ->
    let target_file = Build.Source.as_html Build.Target.site file in
    let pipeline =
      let open Task in
      let+ () = Pipeline.track_file Build.Source.binary
      and+ config
      and+ page, content =
        Yocaml_yaml.Pipeline.read_file_with_metadata (module Page) file
      and+ apply_templates =
        Yocaml_jingoo.read_templates
          [ Build.Source.template "page.html"
          ; Build.Source.template "layout.html"
          ]
      in
      let metadata = Layout.make ~page ~config in
      Logs.debug (fun m -> m "Using metadata: %a@." Layout.pp metadata);
      Omd.of_string content |> Omd.to_html
      |> apply_templates (module Layout) ~metadata
    in
    Action.Static.write_file target_file pipeline

let create_pages =
  Action.batch ~only:`Files ~where:(Path.has_extension "md") Build.Source.pages
    create_page

let build () =
  let open Eff in
  Action.restore_cache Build.Target.cache
  >>= create_assets >>= create_pages
  >>= Action.store_cache Build.Target.cache
