open ANSITerminal

let fmt (styles : style list) : string -> string =
  ANSITerminal.sprintf styles "%s"

let success msg = print_endline @@ "✅  " ^ fmt [ green ] msg
let warning msg = print_endline @@ "⚠️  " ^ fmt [ Bold; yellow ] msg
let info msg = print_endline @@ "ℹ️  " ^ fmt [ blue ] msg
