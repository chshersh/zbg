(** Answer 'Yes' or 'No' *)
type yes_no = No | Yes

val yesno : def:yes_no -> yes_no
(** Read the input from string and parse either 'Yes' or 'No' *)
