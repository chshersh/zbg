open Core

(* Custom types *)

let to_force_flag (flag : bool) : Git.force_flag =
  if flag then Git.Force else Git.NoForce

let to_tag_action (is_delete : bool) : Git.tag_action =
  if is_delete then Git.Delete else Git.Create

(* Commands *)

let cmd_clear =
  Command.basic
    ~summary:"Clear all local changes without the ability to recover"
    (let%map_open.Command force =
       flag "f" ~aliases:[ "--force" ] no_arg
         ~doc:"Clear forcefully without asking any questions"
     in
     fun () -> Git.clear (to_force_flag force))

let cmd_commit =
  Command.basic ~summary:"Commit all local changes"
    (let%map_open.Command message = anon (sequence ("message" %: string)) in
     fun () -> Git.commit message)

let cmd_done =
  Command.basic ~summary:"Switch to the main branch and delete the previous one"
    (Command.Param.return Git.done_)

let cmd_log =
  Command.basic ~summary:"Show pretty log"
    (let%map_open.Command commit =
       anon (maybe_with_default "HEAD" ("commit" %: string))
     in
     fun () -> Git.log commit)

let cmd_new =
  Command.basic ~summary:"Create a new branch <login>/[description]"
    (let%map_open.Command description =
       anon (non_empty_sequence_as_list ("description" %: string))
     in
     fun () -> Git.new_ description)

let cmd_push =
  Command.basic ~summary:"Push the current branch to origin"
    (let%map_open.Command force =
       flag "f" ~aliases:[ "--force-with-lease" ] no_arg
         ~doc:"Push forcefully and override changes"
     in
     fun () -> Git.push (to_force_flag force))

let cmd_rebase =
  Command.basic ~summary:"Rebase current local branch on top of origin/[branch]"
    (let%map_open.Command branch = anon (maybe ("branch" %: string)) in
     fun () -> Git.rebase branch)

let cmd_stash =
  Command.basic ~summary:"Stash all local changes"
    (let%map_open.Command message = anon (maybe ("message" %: string)) in
     fun () -> Git.stash message)

let cmd_status =
  Command.basic ~summary:"Show pretty status of local changes"
    (let%map_open.Command commit =
       anon (maybe_with_default "HEAD" ("commit" %: string))
     in
     fun () -> Git.status commit)

let cmd_switch =
  Command.basic ~summary:"Switch to [branch] and sync it with origin"
    (let%map_open.Command branch = anon (maybe ("branch" %: string)) in
     fun () -> Git.switch branch)

let cmd_sync =
  Command.basic ~summary:"Sync local branch with the remote branch"
    (let%map_open.Command force =
       flag "f" ~aliases:[ "--force" ] no_arg
         ~doc:
           "Sync forcefully by overriding local version with the remote one \
            instead of rebasing"
     in
     fun () -> Git.sync (to_force_flag force))

let cmd_tag =
  Command.basic ~summary:"Create or delete (and push) tags"
    (let%map_open.Command is_delete =
       flag "d" no_arg ~doc:"Delete existing tag instead of creating"
     and tag_name = anon ("tag_name" %: string) in
     fun () -> Git.tag tag_name (to_tag_action is_delete))

let cmd_uncommit =
  Command.basic ~summary:"Undo last commit " (Command.Param.return Git.uncommit)

let cmd_unstash =
  Command.basic ~summary:"Unstash last stashed changes"
    (Command.Param.return Git.unstash)

(* Grouping all commands *)

let command =
  Command.group ~summary:"Easier git workflow"
    [
      ("clear", cmd_clear);
      ("commit", cmd_commit);
      ("done", cmd_done);
      ("log", cmd_log);
      ("new", cmd_new);
      ("push", cmd_push);
      ("rebase", cmd_rebase);
      ("stash", cmd_stash);
      ("status", cmd_status);
      ("switch", cmd_switch);
      ("sync", cmd_sync);
      ("tag", cmd_tag);
      ("uncommit", cmd_uncommit);
      ("unstash", cmd_unstash);
    ]
