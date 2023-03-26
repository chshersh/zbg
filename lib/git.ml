(* INTERNALS *)

let get_current_branch () =
  Process.proc_stdout "git rev-parse --abbrev-ref HEAD"

(* PUBLIC API *)

type force_flag =
    | NoForce
    | Force

let switch branch =
  Process.proc (Printf.sprintf "git checkout %s" branch);
  Process.proc "git pull --ff-only --prune"

let push force =
  let current_branch = get_current_branch () in
  let flag_option =
    match force with
    | NoForce -> ""
    | Force -> "--force"
  in Process.proc (Printf.sprintf "git push --set-upstream origin %s %s" current_branch flag_option)
