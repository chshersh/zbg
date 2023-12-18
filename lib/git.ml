open Base

(* INTERNALS *)

let get_current_branch () : string =
  Process.proc_stdout "git rev-parse --abbrev-ref HEAD"

let fetch_main_branch () : string =
  let remote_main_branch =
    Process.proc_stdout "git rev-parse --abbrev-ref origin/HEAD"
  in
  Process.proc_stdout @@ Printf.sprintf "basename %s" remote_main_branch
(* TODO: use pure function *)

let branch_or_main (branch_opt : string option) : string =
  match branch_opt with
  | Some branch -> branch
  | None -> fetch_main_branch ()

(* Read user login from user.login in git config. *)
let get_login () : string option =
  let home_dir = Unix.getenv "HOME" in
  let login =
    Process.proc_stdout
    @@ Printf.sprintf "HOME=%s git config user.login" home_dir
  in
  if String.is_empty login then None else Some login

let mk_branch_description (description : string list) : string =
  let is_valid_char c =
    Char.is_alphanum c
    || Char.is_whitespace c
    || List.exists ~f:(Char.( = ) c) [ '/'; '-'; '_' ]
  in
  Extended_string.unwords description
  |> String.filter ~f:is_valid_char
  |> Extended_string.words
  |> String.concat ~sep:"-"

(* PUBLIC API *)

type force_flag = NoForce | Force
type tag_action = Delete | Create

let clear force =
  let clear_changes () =
    Process.proc "git add .";
    Process.proc "git reset --hard"
  in

  let prompt =
    "'zbg clear' deletes all uncommited changes !!! PERMANENTLY !!!\n\
    \   HINT: If you want to recover them later, use 'zbg stash' instead.\n\
    \   Are you sure you to delete all uncommited changes? (y/N)"
  in

  match force with
  | Force -> clear_changes ()
  | NoForce -> (
      Message.warning prompt;
      let open Prompt in
      match yesno ~def:No with
      | No -> Message.info "Aborting 'zbg clear'"
      | Yes -> clear_changes ())

let commit message_words =
  let message = Extended_string.unwords message_words in
  Process.proc "git add .";
  match message with
  | "" -> Process.proc "git commit"
  | message -> Process.proc @@ Printf.sprintf "git commit --message=%S" message

let log commit =
  (* Log format is:

     ➡️ ecf8c6f: Implement 'uncommit'  (tag: v0.0.0)
        Author: Dmitrii Kovanikov <kovanikov@gmail.com>
          Date: 26 Mar 2023 18:38:58 +0100
  *)
  let log_format =
    "➡️  %C(bold green)%h%C(reset): %C(italic cyan)%s%C(reset) \
     %C(yellow)%d%C(reset)%n     %C(bold blue)Author%C(reset): %an \
     <%ae>%n       %C(bold blue)Date%C(reset): %cd%n"
  in
  let date_format = "%d %b %Y %H:%M:%S %z" in
  Process.proc_silent
  @@ Printf.sprintf "git log --date='format:%s' --format='format: %s' %s"
       date_format log_format commit

let new_ description =
  let create_branch branch_name =
    Process.proc @@ Printf.sprintf "git checkout -b %s" branch_name
  in
  let branch_description = mk_branch_description description in
  let branch_name =
    match get_login () with
    | Some login -> login ^ "/" ^ branch_description
    | None ->
        let warning_msg =
          "Unknown user login! Set it globally via:\n\n\
          \    git config --global user.login <your_github_username>"
        in
        Message.warning warning_msg;
        branch_description
  in
  create_branch branch_name

let push force =
  let current_branch = get_current_branch () in
  let flag_option =
    match force with
    | NoForce -> ""
    | Force -> "--force-with-lease"
  in
  Process.proc
  @@ Printf.sprintf "git push --set-upstream origin %s %s" current_branch
       flag_option

let rebase branch_opt =
  let branch = branch_or_main branch_opt in
  Process.proc @@ Printf.sprintf "git fetch origin %s" branch;
  Process.proc @@ Printf.sprintf "git rebase origin/%s" branch

let stash msg_opt =
  let msg_arg =
    match msg_opt with
    | None -> ""
    | Some msg -> Printf.sprintf "--message=%S" msg
  in
  Process.proc @@ Printf.sprintf "git stash push --include-untracked %s" msg_arg

let status = Status.status

let switch branch_opt =
  let branch = branch_or_main branch_opt in
  Process.proc @@ Printf.sprintf "git checkout %s" branch;
  Process.proc "git pull --ff-only --prune"

let sync force =
  let current_branch = get_current_branch () in
  match force with
  | NoForce ->
      Process.proc
      @@ Printf.sprintf "git pull --ff-only origin %s" current_branch
  | Force ->
      Process.proc @@ Printf.sprintf "git fetch origin %s" current_branch;
      Process.proc @@ Printf.sprintf "git reset --hard origin/%s" current_branch

let tag tag_name tag_action =
  match tag_action with
  | Create ->
      (* create tag locally *)
      Process.proc
      @@ Printf.sprintf
           "git tag --annotate %s --message='Tag for the %s release'" tag_name
           tag_name;
      (* push tags *)
      Process.proc "git push origin --tags"
  | Delete ->
      (* delete tag locally *)
      Process.proc @@ Printf.sprintf "git tag --delete %s" tag_name;
      (* delete tag remotely *)
      Process.proc @@ Printf.sprintf "git push --delete origin %s" tag_name

let uncommit () = Process.proc "git reset HEAD~1"
let unstash () = Process.proc "git stash pop"

let done_ () =
  let prev_branch = get_current_branch () in
  let main_branch = fetch_main_branch () in
  switch (Some main_branch);
  if String.( <> ) prev_branch main_branch then
    Process.proc @@ Printf.sprintf "git branch --delete %s" prev_branch
