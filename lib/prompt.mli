(* Answer 'Yes' or 'No' *)
type yes_no = No | Yes

(* Read the input from string and parse either 'Yes' or 'No' *)
val yesno : def:yes_no -> yes_no
