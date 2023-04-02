(* Set Force when [-f|--force] flag is provided *)
type force_flag =
    | NoForce
    | Force

(* Action to do with the tag: delete or create *)
type tag_action =
    | Delete
    | Create

(** Clear all local changes unrecoverably. *)
val clear : force_flag -> unit

(** Commit all local changes. *)
val commit : string -> unit

(** Show pretty log. *)
val log : string -> unit

(** Push the current branch to origin. *)
val push : force_flag -> unit

(** Rebase local branch on top of origin/<branch>. *)
val rebase : string option -> unit

(** Stash all local changes. *)
val stash : string option -> unit

(** Show pretty status of local changes. *)
val status : string -> unit

(** Switch to a new branch and update to the latest version of origin. *)
val switch : string -> unit

(** Sync local branch with the remote branch. *)
val sync : force_flag -> unit

(** Create or delete tag. *)
val tag : string -> tag_action -> unit

(** Undo last commit. *)
val uncommit : unit -> unit

(** Unstash latest changes. *)
val unstash : unit -> unit
