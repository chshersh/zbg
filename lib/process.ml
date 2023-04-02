let proc cmd =
  Printf.eprintf "🐚  %s\n%!" cmd;
  let _exit_code = Unix.system cmd in
  ()

let collect_chan (channel : in_channel) : string =
  let rec loop acc =
    match input_line channel with
    | exception End_of_file -> acc
    | line -> loop (acc ^ line ^ "\n")
  in
  loop ""

let proc_stdout cmd =
  let ((proc_stdout, _proc_stdin, _proc_stderr) as process) = Unix.open_process_full cmd [||] in
  let stdout_result = collect_chan proc_stdout in
  let _ = Unix.close_process_full process in
  String.trim stdout_result