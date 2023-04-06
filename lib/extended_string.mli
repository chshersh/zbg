val unlines : string list -> string
(** Combine strings with the line separator. *)

val unwords : string list -> string
(** Combine strings with a single whitespace. *)

val words : string -> string list
(** Split the string into words. *)

val fill_right : int -> string -> string
(** Fill the string with the spaces on the right side. *)

val fill_left : int -> string -> string
(** Fill the string with the spaces on the left side. *)
