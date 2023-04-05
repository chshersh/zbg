(lang dune 3.7)

(name zbg)

(generate_opam_files true)

(source
 (github chshersh/zbg))

(authors "Dmitrii Kovanikov")
(maintainers "Dmitrii Kovanikov")

(license LICENSE)

(documentation https://url/to/documentation)

(package
 (name zbg)
 (synopsis "Zero bullshit git")
 (description "A CLI tool to use git without ceremony")
 (depends
   ocaml
   dune
   ANSITerminal
   core
   core_unix.command_unix
   ppx_assert
   ppx_deriving.ord
   ppx_inline_test
   ppx_jane
 )
 (tags
  (cli tool git workflow)))
