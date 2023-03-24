let switch branch =
  Process.proc (Printf.sprintf "git checkout %s" branch);
  Process.proc "git pull --ff-only --prune"