open Base
open Extended_string
open Message

(* Internal functions *)

(* Extract the length of the longest element by a given string extractor. *)
let max_len_on : 'a. ('a -> string) -> 'a list -> int =
 fun f l ->
  List.map ~f:(fun a -> String.length (f a)) l
  |> List.max_elt ~compare:Int.compare
  |> Option.value ~default:0

(* Perform a given action by first staging the files returned by the given git
   command and then resetting the files back. *)
let with_staged_files : 'a. string -> (unit -> 'a) -> 'a =
 fun git_cmd action ->
  let stage_files =
    List.iter ~f:(fun file ->
        Fn.ignore @@ Process.proc_stdout @@ Printf.sprintf "git add %s" file)
  in
  let reset_files =
    List.iter ~f:(fun file ->
        Fn.ignore
        @@ Process.proc_stdout
        @@ Printf.sprintf "git reset -- %s" file)
  in
  let files_to_stage = String.split_lines @@ Process.proc_stdout git_cmd in
  stage_files files_to_stage;
  Exn.protect ~f:action ~finally:(fun () -> reset_files files_to_stage)

(* Perform the given action by staging all deleted files first. *)
let with_deleted_files =
  with_staged_files "git ls-files --deleted --exclude-standard"

(* Perform the given action by staging all untracked files first. *)
let with_untracked_files =
  with_staged_files "git ls-files --others --exclude-standard"

(* API *)

(* Enum for all possible types of file modifications. *)
type patch_type =
  | Added
  | Copied
  | Deleted
  | Modified
  | Renamed
  | TypeChanged
  | Unmerged
  | Unknown
  | BrokenPairing
[@@deriving sexp, ord]

(* Parses 'patch_type' from string representation.

   **NOTE:** 'Renamed' and 'Copied' contain an additional similarity percentage
   *between the two files. So we parse only the first letter.

   Examples of potential values:

     * 'A' for newly added files
     * 'M' for modified files
     * 'R100' for renamed files, where 100 denotes a similarity percentage
     * 'C075' for copied files, where 75 denotes a similarity percentage
*)
let parse_patch_type (status_txt : string) : patch_type option =
  match status_txt.[0] with
  | 'A' -> Some Added
  | 'C' -> Some Copied
  | 'D' -> Some Deleted
  | 'M' -> Some Modified
  | 'R' -> Some Renamed
  | 'T' -> Some TypeChanged
  | 'U' -> Some Unmerged
  | 'X' -> Some Unknown
  | 'B' -> Some BrokenPairing
  | _ -> None
  | exception Invalid_argument _ -> None

(* Display 'patch_type' in colorful and expanded text. *)
let display_patch_type (patch_type : patch_type) : string =
  let open ANSITerminal in
  match patch_type with
  | Added -> fmt [ Bold; green ] "added"
  | Copied -> fmt [ Bold; magenta ] "copied"
  | Deleted -> fmt [ Bold; red ] "deleted"
  | Modified -> fmt [ Bold; blue ] "modified"
  | Renamed -> fmt [ Bold; yellow ] "renamed"
  | TypeChanged -> fmt [ Bold; cyan ] "type-changed"
  | Unmerged -> fmt [ Bold ] "unmerged"
  | Unknown -> fmt [ Bold ] "unknown"
  | BrokenPairing -> fmt [ Bold ] "broken"

(* Output of `git diff --name-status` stored in a structured way.

   ```
   $ git diff HEAD --name-status
   M       lib/cli.ml
   A       lib/status.ml
   R100    pancake       muffin
   ```
*)
type file_status = {
  patch_type : patch_type;
  file : string; (* single files or two concatenated files in case of R or C *)
}
[@@deriving sexp, ord]

(* Parses the output of `git diff --name-status`.

   **NOTE:** When a file was renamed, both the previous and the new filename are
   given.

   This function parses list of strings from the following format:

   ```
   <patch-type> <filename>
   <patch-type> <old-filename> <new-filename>
   ```

   Example:

   ```
    M     README.md
    A     jam
    R100  pancake       muffin
   ```
*)
let parse_diff_name_status (status : string) : file_status option =
  match words status with
  | ty :: files ->
      Option.map (parse_patch_type ty) ~f:(fun patch_type ->
          { patch_type; file = unwords files })
  | _ -> None

(* Get the list of all changed files and their change statuses. *)
let get_file_statuses (commit : string) : file_status list =
  Process.proc_stdout (Printf.sprintf "git diff --name-status %s" commit)
  |> String.split_lines
  |> List.filter_map ~f:parse_diff_name_status
  |> List.sort ~compare:(fun ds1 ds2 -> String.compare ds1.file ds2.file)

(* A data type for storing the diff as + and - *)
type diff_stat = Raw of string | Signs of { pluses : int; minuses : int }
[@@deriving sexp, ord]

(* Split a single string like +++-- into (+++, --) *)
let split_signs (signs : string) : diff_stat =
  let pluses = String.length @@ String.rstrip ~drop:(Char.( = ) '-') signs in
  let minuses = String.length @@ String.lstrip ~drop:(Char.( = ) '+') signs in
  Signs { pluses; minuses }

(* Output of `git diff --stat` stored in a structured way.

   ```
   $ git diff HEAD --stat
    lib/cli.ml  | 11 +++++------
    lib/dune    |  6 +++++-
    lib/git.ml  |  2 ++
    lib/git.mli |  3 +++
    4 files changed, 15 insertions(+), 7 deletions(-)
   ```
*)
type diff_details = {
  file : string; (* file name *)
  change_count : string; (* number of changed lines*)
  stat : diff_stat;
}
[@@deriving sexp, ord]

(* Split the output of `git diff --stat` into the list of words:

   Example input:

   ```
   pancake                |   2 ++
   test/{st => org/st}    |   3 ---
   ```

   Output:

   ```
   ["pancake"; "2"; "++"]
   ["test/st"; "=>"; "org/st"; "3"; "---"]
   ```
*)
let split_stats (stat : string) : string list =
  match String.lsplit2 stat ~on:'|' with
  | None -> [ stat ]
  | Some (l, r) -> words l @ words r

(* Attempts to expand shortened paths which can appear in `git diff --stat`.

   **NOTE:** This function takes a tuple of the part before and after the arrow.

   Examples of possible inputs and their resulting expansions:

   ```
         Git output         |    Left    |   Right   |        Result
    a.in      => b.out      |  a.in      |  b.out    | a.in     => b.out
    test/{bar => baz}       |  test/{bar |  baz}     | test/bar => test/baz
    test/{bar => a1/baz}    |  test/{bar |  a1/baz}  | test/bar => test/a1/baz
    test/{    => bar}/baz   |  test/{    |  bar}/baz | test/baz => test/bar/baz
   ```
*)
let expand_renamed_paths (left : string) (right : string) : string =
  let parent, middle_components, suffix =
    let parent, left_component =
      match String.lsplit2 left ~on:'{' with
      | None -> ("", left)
      | Some res -> res
    in
    let right_component, suffix =
      match String.rsplit2 right ~on:'}' with
      | None -> (right, "")
      | Some res -> res
    in
    (parent, [ left_component; right_component ], suffix)
  in
  let append_path (p1 : string) (p2 : string) =
    if String.is_empty p1 then p2
    else if String.is_empty p2 then p1
    else if Char.( = ) p1.[String.length p1 - 1] '/' && Stdlib.( == ) p2.[0] '/'
    then p1 ^ String.drop_prefix p2 1
    else p1 ^ p2
  in

  let mk_path comp = append_path parent (append_path comp suffix) in
  String.concat ~sep:" => " (List.map middle_components ~f:mk_path)

(* Internal function for [parse_diff_stat] that takes diff stat as a list of words. *)
let parse_diff_details_words (words : string list) : diff_details option =
  match words with
  | prev_file :: "=>" :: new_file :: change_count :: rest ->
      Some
        {
          file = expand_renamed_paths prev_file new_file;
          change_count;
          stat = split_signs @@ unwords rest;
        }
  | file :: "Bin" :: rest ->
      Some { file; change_count = "Bin"; stat = Raw (unwords rest) }
  | file :: change_count :: signs ->
      Some { file; change_count; stat = split_signs @@ String.concat signs }
  | _ -> None

(* Parses a single line from the `git diff --stat` output.

   **NOTE:** This function also handles special case of binary files.

   Each line has the following format:

   ```
   <filename> | <n> <pluses-and-minuses>
   ```

   Example:

   ```
   test/{st => org/st}    |   2 --
   cake => muffin         |   0
   README.md              |   4 ++++
   pancake                |   2 ++
   .pancake.un~           | Bin 0 -> 412 bytes
   ```
*)
let parse_diff_details (stat_line : string) : diff_details option =
  split_stats stat_line |> parse_diff_details_words

(* Return `diff_stat` for a single file from the parsed result of the following
   git command:

   ```
   git diff <commit> --stat <path>
   ```

   Example:

   ```
   $ git diff HEAD --stat lib/cli.ml
    lib/cli.ml | 11 +++++------
    1 file changed, 5 insertions(+), 6 deletions(-)
   ```
*)

let get_git_base_dir =
  Process.proc_stdout "git rev-parse --show-toplevel"
  |> String.rstrip ~drop:(fun c -> Char.( = ) c '\n')

let get_file_diff_stat ~(commit : string) ~(file : string) : diff_details =
  let diff_stat =
    Process.proc_stdout
    @@ Printf.sprintf "git diff %s --stat --color=never -- %s" commit
         (get_git_base_dir ^ "/" ^ file)
  in
  match String.split_lines diff_stat with
  | stat_line :: _ ->
      Option.value
        (parse_diff_details stat_line)
        ~default:
          { file; change_count = "0"; stat = Raw "<unable to parse stat>" }
  | _ -> { file; change_count = "0"; stat = Raw "<unable to match file>" }

(* Return `true` if `git rebase` is currently in progress. *)
let is_rebase_in_progress () : bool =
  let git_dirs = Process.proc_stdout "ls `git rev-parse --git-dir`" in
  String.is_substring ~substring:"rebase" git_dirs

(* Helpful message for `git rebase` *)
let git_rebase_help =
  let open ANSITerminal in
  let header =
    fmt [ Bold; blue ] "Rebase is currently in progress! Possible actions:"
  in
  let rebase_continue =
    fmt [ yellow ] "git rebase --continue " ^ ": after fixing all conflicts"
  in
  let rebase_skip =
    fmt [ yellow ] "git rebase --skip     " ^ ": to skip this patch"
  in
  let rebase_abort =
    fmt [ yellow ] "git rebase --abort    " ^ ": to abort the current rebase"
  in
  unlines
    [
      header;
      "    " ^ rebase_continue;
      "    " ^ rebase_skip;
      "    " ^ rebase_abort;
    ]

(* Show all files that currently have conflicts. *)
let show_conflict_files () =
  let diff_conflict_files =
    Process.proc_stdout "git diff --name-only --diff-filter=U"
  in
  match String.split_lines diff_conflict_files with
  | [] -> ()
  | conflict_files ->
      let header =
        fmt [ ANSITerminal.Bold; ANSITerminal.red ] "Conflict files:"
      in
      let files = List.map conflict_files ~f:(fun file -> "    " ^ file) in
      Core.print_endline (unlines (header :: files))

type change_summary = {
  patch_type : string;
  file : string;
  change_count : string;
  diff_stat : diff_stat;
}

let fmt_diff_stats (change_summaries : change_summary list) : string =
  let patch_type_size = max_len_on (fun x -> x.patch_type) change_summaries in
  let file_size = max_len_on (fun x -> x.file) change_summaries in
  let change_count_size =
    max_len_on (fun x -> x.change_count) change_summaries
  in

  let open ANSITerminal in
  let format_diff_stat = function
    | Raw str -> fmt [ cyan ] str
    | Signs signs ->
        let pluses =
          fmt [ green ]
          @@ String.concat
          @@ List.init signs.pluses ~f:(fun _ -> "\u{25A0}")
        in
        let minuses =
          fmt [ red ]
          @@ String.concat
          @@ List.init signs.minuses ~f:(fun _ -> "\u{25A0}")
        in
        pluses ^ minuses
  in

  let format_row (change : change_summary) =
    let patch_type = fill_right patch_type_size change.patch_type in
    let file = fill_right file_size change.file in
    let change_count = fill_left change_count_size change.change_count in
    let stat = format_diff_stat change.diff_stat in
    Printf.sprintf " %s  %s | %s %s" patch_type file change_count stat
  in

  unlines (List.map ~f:format_row change_summaries)

let print_file_statuses commit (file_statuses : file_status list) =
  let change_summaries =
    List.map file_statuses ~f:(fun file_status ->
        let diff_details = get_file_diff_stat ~commit ~file:file_status.file in
        {
          patch_type = display_patch_type file_status.patch_type;
          file = diff_details.file;
          change_count = diff_details.change_count;
          diff_stat = diff_details.stat;
        })
  in
  Core.print_endline (fmt_diff_stats change_summaries)

(* Show pretty diff in the following format:

   ```
   modified  lib/status.ml           | 6 +++---
   modified  test/extended_string.ml | 8 ++++----
   ```

   **NOTE:** Assumes that all deleted and new files are staged.
*)
let show_pretty_diff (commit : string) : unit =
  (* Show rebase help message if rebase is currently in progress *)
  if is_rebase_in_progress () then (
    Core.print_endline git_rebase_help;
    show_conflict_files ());
  let file_statuses = get_file_statuses commit in
  match file_statuses with
  | [] -> success "No changes to commit!"
  | file_statuses -> print_file_statuses commit file_statuses

let status commit =
  with_deleted_files (fun () ->
      with_untracked_files (fun () -> show_pretty_diff commit))
