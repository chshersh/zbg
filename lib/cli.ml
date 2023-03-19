open Core

let start =
  Command.basic
    ~summary:"Create a new branch <login>/[description]"
    (let%map_open.Command description = anon ("description" %: string) in
      fun () ->
        printf "git checkout -b <login>/%s\n%!" description)

let update =
  Command.basic
    ~summary:"Rebase current branch on top of remote origin/[branch]"
    (let%map_open.Command branch = anon ("branch" %: string) in
      fun () ->
        printf "git fetch origin %s\n%!" branch;
        printf "git rebase origin/%s\n%!" branch;
    )

let command =
  Command.group
    ~summary:"Manipulate dates"
    [ "start", start; "update", update ]