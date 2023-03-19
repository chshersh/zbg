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