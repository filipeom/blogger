(lang dune 3.15)

(generate_opam_files true)

(authors "Filipe Marques <filipe.s.marques@tecnico.ulisboa.pt>")

(license "MIT")

(package
 (name filipeom)
 (synopsis "My home on the internet")
 (depends
  dune
  cmdliner
  (ocaml
   (>= "5.2.0"))
  yocaml
  yocaml_unix
  ))
