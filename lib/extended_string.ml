open Base

let unlines : string list -> string = String.concat ~sep:"\n"
let unwords : string list -> string = String.concat ~sep:" "

let words (s : string) : string list =
  String.split_on_chars ~on:[ ' '; '\t'; '\n' ] s
  |> List.filter ~f:(fun s -> not (String.is_empty s))

let justify_left (n : int) (s : string) : string =
  s ^ String.make (n - String.length s) ' '

let justify_right (n : int) (s : string) : string =
  String.make (n - String.length s) ' ' ^ s
