(* INTERNALS *)

let get_current_branch () =
  Process.proc_stdout "git rev-parse --abbrev-ref HEAD"

let fetch_main_branch () =
  let remote_main_branch = Process.proc_stdout "git rev-parse --abbrev-ref origin/HEAD" in
  Process.proc_stdout (Printf.sprintf "basename %s" remote_main_branch) (* TODO: use pure function *)

let branch_or_main branch_opt =
  match branch_opt with
  | Some branch -> branch
  | None -> fetch_main_branch ()

(* PUBLIC API *)

type force_flag =
    | NoForce
    | Force

let clear force =
  let clear_changes () =
    Process.proc "git add .";
    Process.proc "git reset --hard"
  in

  let prompt = "\
* 'zbg clear' deletes all uncommited changes !!! PERMANENTLY !!!
  Hint: If you want to recover them later, use 'zbg stash' instead.
  Are you sure you to delete all uncommited changes? (y/N)
"
  in

  match force with
  | Force -> clear_changes ()
  | NoForce ->
    Printf.printf "%s%!" prompt;
    let open Prompt in
    match yesno ~def:No with
    | No -> print_endline "Aborting 'zbg clear'"
    | Yes -> clear_changes ()

let commit message =
  Process.proc "git add .";
  Process.proc (Printf.sprintf "git commit --message=\"%s\"" message) (* TODO: Escape quotes in message *)

let push force =
  let current_branch = get_current_branch () in
  let flag_option =
    match force with
    | NoForce -> ""
    | Force -> "--force"
  in Process.proc (Printf.sprintf "git push --set-upstream origin %s %s" current_branch flag_option)

let rebase branch_opt =
  let branch = branch_or_main branch_opt in
  Process.proc (Printf.sprintf "git fetch origin %s" branch);
  Process.proc (Printf.sprintf "git rebase origin/%s" branch) (* TODO: handle failed rebase *)

let stash msg_opt =
  let msg_arg =
    match msg_opt with
    | None -> ""
    | Some msg -> Printf.sprintf "--message='%s'" msg (* TODO: proper escaping *)
  in
  Process.proc (Printf.sprintf "git stash push --include-untracked %s" msg_arg)

let switch branch =
  Process.proc (Printf.sprintf "git checkout %s" branch);
  Process.proc "git pull --ff-only --prune"

let sync force =
  let current_branch = get_current_branch () in
  match force with
    | NoForce ->
      Process.proc (Printf.sprintf "git pull --ff-only origin %s" current_branch)
    | Force ->
      Process.proc (Printf.sprintf "git fetch origin %s" current_branch);
      Process.proc (Printf.sprintf "git reset --hard origin/%s" current_branch)

let unstash () =
  Process.proc "git stash pop"