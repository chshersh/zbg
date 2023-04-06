val fmt : ANSITerminal.style list -> string -> string
(** Format a string with the given list of styles. *)

val success : string -> unit
(** Print green message with the success emoji. *)

val warning : string -> unit
(** Print yellow message with the warning emoji. *)

val info : string -> unit
(** Print blue message with the info emoji. *)
