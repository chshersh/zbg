(* INTERNALS *)

let get_current_branch () =
  Process.proc_stdout "git rev-parse --abbrev-ref HEAD"

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

let push force =
  let current_branch = get_current_branch () in
  let flag_option =
    match force with
    | NoForce -> ""
    | Force -> "--force"
  in Process.proc (Printf.sprintf "git push --set-upstream origin %s %s" current_branch flag_option)

let stash msg =
  let msg_arg =
    match msg with
    | None -> ""
    | Some msg -> Printf.sprintf "--mesage='%s'" msg (* TODO: proper escaping *)
  in
  Process.proc (Printf.sprintf "git stash push --include-untracked %s" msg_arg)

let switch branch =
  Process.proc (Printf.sprintf "git checkout %s" branch);
  Process.proc "git pull --ff-only --prune"

let unstash () =
  Process.proc "git stash pop"