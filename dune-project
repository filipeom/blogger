(lang dune 3.20)

(generate_opam_files true)

(source
 (github filipeom/blogger))

(authors "Filipe Marques <filipe.s.marques@tecnico.ulisboa.pt>")

(maintainers "Filipe Marques <filipe.s.marques@tecnico.ulisboa.pt>")

(license "MIT")

(package
 (name blogger)
 (synopsis "Blogger")
 (depends
  dune
  cmdliner
  (ocaml
   (>= "5.3.0"))
  bos
  cmdliner
  cmarkit
  fpath
  logs
  jingoo
  yaml
  ppx_deriving
  ppx_deriving_yaml))
