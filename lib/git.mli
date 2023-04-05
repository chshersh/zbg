(* Set Force when [-f|--force] flag is provided *)
type force_flag = NoForce | Force

(* Action to do with the tag: delete or create *)
type tag_action = Delete | Create

val clear : force_flag -> unit
(** Clear all local changes unrecoverably. *)

val commit : string -> unit
(** Commit all local changes. *)

val log : string -> unit
(** Show pretty log. *)

val new_ : string list -> unit
(** Create new branch. *)

val push : force_flag -> unit
(** Push the current branch to origin. *)

val rebase : string option -> unit
(** Rebase local branch on top of origin/<branch>. *)

val stash : string option -> unit
(** Stash all local changes. *)

val status : string -> unit
(** Show pretty status of local changes. *)

val switch : string -> unit
(** Switch to a new branch and update to the latest version of origin. *)

val sync : force_flag -> unit
(** Sync local branch with the remote branch. *)

val tag : string -> tag_action -> unit
(** Create or delete tag. *)

val uncommit : unit -> unit
(** Undo last commit. *)

val unstash : unit -> unit
(** Unstash latest changes. *)
