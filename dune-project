(lang dune 3.7)

(name bfg)

(generate_opam_files true)

(source
 (github chshersh/bfg))

(authors "Dmitrii Kovanikov")
(maintainers "Dmitrii Kovanikov")

(license LICENSE)

(documentation https://url/to/documentation)

(package
 (name bfg)
 (synopsis "Blazingly fast git")
 (description "A CLI tool to use git blazingly fast")
 (depends ocaml dune)
 (tags
  (cli tool git workflow)))
