val proc : string -> unit
(** Run a given string as an external process with arguments.

    Redirect the called process stdout and stderr to the current process stdout.

    Also print the command with a pretty prompt. *)

val proc_silent : string -> unit
(** Like [proc] but doesn't print the specified command. *)

val proc_stdout : string -> string
(** Run a given string as an external process with arguments.

    Return the process stdout as the result.

    Don't print the process output. *)
