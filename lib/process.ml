let print_chan (channel : in_channel) =
  let rec loop () =
      let () = print_endline (input_line channel) in
      loop ()
    in
  try loop ()
  with End_of_file -> ();;

let proc cmd =
  Printf.eprintf "> %s\n%!" cmd;
  let ((proc_stdout, _proc_stdin, proc_stderr) as process) = Unix.open_process_full cmd [||] in
  print_chan proc_stdout;
  print_chan proc_stderr;
  let _ = Unix.close_process_full process in
  ()

let collect_chan (channel : in_channel) =
  let rec loop acc =
      let line = input_line channel in
      loop (acc ^ line ^ "\n")
    in
  try loop ""
  with End_of_file -> "";;

let proc_stdout cmd =
  let ((proc_stdout, _proc_stdin, _proc_stderr) as process) = Unix.open_process_full cmd [||] in
  let stdout_result = collect_chan proc_stdout in
  let _ = Unix.close_process_full process in
  String.trim stdout_result