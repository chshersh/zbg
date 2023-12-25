let mk_home_cmd cmd =
  let home_dir = Unix.getenv "HOME" in
  Printf.sprintf "HOME=%s %s" home_dir cmd

let proc_silent cmd =
  let _exit_code = Unix.system (mk_home_cmd cmd) in
  ()

let proc cmd =
  Printf.eprintf "🐚  %s\n%!" cmd;
  proc_silent cmd

let collect_chan (channel : in_channel) : string =
  let rec loop acc =
    match input_line channel with
    | exception End_of_file -> acc
    | line -> loop (acc ^ line ^ "\n")
  in
  loop ""

let proc_stdout cmd =
  let ((proc_stdout, _proc_stdin, _proc_stderr) as process) =
    Unix.open_process_full (mk_home_cmd cmd) [||]
  in
  let stdout_result = collect_chan proc_stdout in
  let _ = Unix.close_process_full process in
  String.trim stdout_result
