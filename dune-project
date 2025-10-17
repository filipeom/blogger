(lang dune 3.20)

(generate_opam_files true)

(source
 (github filipeom/blogger))

(authors "Filipe Marques <filipe.s.marques@tecnico.ulisboa.pt>")

(maintainers "Filipe Marques <filipe.s.marques@tecnico.ulisboa.pt>")

(license "MIT")

(package
 (name blogger)
 (synopsis "My home on the internet")
 (depends
  dune
  cmdliner
  (ocaml
   (>= "5.2.0"))
  omd
  jingoo
  fpath
  bos))
