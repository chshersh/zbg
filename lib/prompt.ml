type yes_no = No | Yes

let parse_yes_no ~def str =
  match str |> String.trim |> String.lowercase_ascii with
  | "" ->
      Some def
  | "y"
  | "ys"
  | "yes" ->
      Some Yes
  | "n"
  | "no" ->
      Some No
  | _ ->
      None

let rec yesno ~def =
  let input = read_line () in
  match parse_yes_no ~def input with
  | Some answer ->
      answer
  | None ->
      Printf.printf "Invalid answer '%s'. Expected yes or no (or y, or n)\n%!"
        input;
      yesno ~def
