open Core

(* Custom types *)

let to_force_flag (flag : bool) =
  if flag then Git.Force else Git.NoForce


(* Commands *)

let cmd_switch =
  Command.basic
    ~summary:"Switch to [branch] and sync it with origin"
    (let%map_open.Command
      branch = anon (maybe_with_default "main" ("branch" %: string))
    in fun () -> Git.switch branch)

let cmd_push =
  Command.basic
    ~summary:"Push the current branch to origin"
    (let%map_open.Command
      force = flag "f" no_arg ~doc:"Push forcefully and override changes"
    in fun () -> Git.push (to_force_flag force))

let cmd_clear =
  Command.basic
    ~summary:"Clear all local changes without the ability to recover"
    (let%map_open.Command
      force = flag "f" no_arg ~doc:"Clear forcefully without asking any questions"
    in fun () -> Git.clear (to_force_flag force))

let cmd_new =
  Command.basic
    ~summary:"Create a new branch <login>/[description]"
    (let%map_open.Command description = anon ("description" %: string) in
      fun () ->
        printf "git checkout -b <login>/%s\n%!" description)

let cmd_update =
  Command.basic
    ~summary:"Rebase current branch on top of remote origin/[branch]"
    (let%map_open.Command branch = anon ("branch" %: string) in
      fun () ->
        printf "git fetch origin %s\n%!" branch;
        printf "git rebase origin/%s\n%!" branch;
    )

let cmd_status =
  Command.basic
    ~summary:"Show pretty current status"
    (Command.Param.return
      (fun () -> Process.proc "git status")
    )

(* Grouping all commands *)

let command =
  Command.group
    ~summary:"Manipulate git workflow"
    [ "switch", cmd_switch
    ; "push", cmd_push
    ; "clear", cmd_clear
    ; "status", cmd_status
    ; "new", cmd_new
    ; "update", cmd_update
    ]

(*
TODO:

- status
- rebase (fresh)
- update (sync)
- stash
- unstash
- log
- new
- tag
- uncommit

Optional:

- fix
- commit
- amend

With API:

- issue
- milestone
*)