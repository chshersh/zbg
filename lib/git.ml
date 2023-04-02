(* INTERNALS *)

let get_current_branch () : string =
  Process.proc_stdout "git rev-parse --abbrev-ref HEAD"

let fetch_main_branch () : string =
  let remote_main_branch = Process.proc_stdout "git rev-parse --abbrev-ref origin/HEAD" in
  Process.proc_stdout (Printf.sprintf "basename %s" remote_main_branch) (* TODO: use pure function *)

let branch_or_main (branch_opt : string option) : string =
  match branch_opt with
  | Some branch -> branch
  | None -> fetch_main_branch ()

(* PUBLIC API *)

type force_flag =
    | NoForce
    | Force

type tag_action =
    | Delete
    | Create

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

let log commit =
  (* Log format is:

  ➡️ ecf8c6f: Implement 'uncommit'  (tag: v0.0.0)
     Author: Dmitrii Kovanikov <kovanikov@gmail.com>
       Date: 26 Mar 2023 18:38:58 +0100

  *)
  let log_format =
    "➡️  %C(bold green)%h%C(reset): %C(italic cyan)%s%C(reset) %C(yellow)%d%C(reset)%n \
   \    %C(bold blue)Author%C(reset): %an <%ae>%n \
   \      %C(bold blue)Date%C(reset): %cd%n"
  in
  let date_format = "%d %b %Y %H:%M:%S %z" in
  Process.proc (Printf.sprintf
      "git log \
      --date='format:%s' \
      --format='format: %s' \
      %s"
      date_format
      log_format
      commit
  )

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

let tag tag_name tag_action =
  match tag_action with
    | Create ->
      (* create tag locally *)
      Process.proc (Printf.sprintf "git tag --annotate %s --message='Tag for the %s release'" tag_name tag_name);
      (* push tags *)
      Process.proc "git push origin --tags"
    | Delete ->
      (* delete tag locally *)
      Process.proc (Printf.sprintf "git tag --delete %s" tag_name);
      (* delete tag remotely *)
      Process.proc (Printf.sprintf "git push --delete origin %s" tag_name)

let uncommit () =
  Process.proc "git reset HEAD~1"

let unstash () =
  Process.proc "git stash pop"