(* Combine strings with the line separator. *)
val unlines : string list -> string

(* Combine strings with a single whitespace. *)
val unwords : string list -> string

(* Split the string into words. *)
val words : string -> string list

(* Fill the string with the spaces on the right side. *)
val justify_left : int -> string -> string

(* Fill the string with the spaces on the left side. *)
val justify_right : int -> string -> string