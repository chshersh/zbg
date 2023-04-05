open Base
open Zbg

(* patch_type *)

let%test_unit "parse_patch_type" =
  [%test_eq: Status.patch_type option]
    (Status.parse_patch_type "M")
    (Some Status.Modified)

(* file_status *)

let%test_unit "parse_diff_name_status_added" =
  [%test_eq: Status.file_status option]
    (Status.parse_diff_name_status "A     README.md")
    (Some { patch_type = Status.Added; file = "README.md" })

let%test_unit "parse_diff_name_status_renamed" =
  [%test_eq: Status.file_status option]
    (Status.parse_diff_name_status "R100  pancake       muffin")
    (Some { patch_type = Status.Renamed; file = "pancake muffin" })

(* expand_renamed_statuses *)

let%test_unit "expand_renamed_statuses_simple" =
  [%test_eq: string]
    (Status.expand_renamed_paths "a.in" "b.out")
    "a.in => b.out"

let%test_unit "expand_renamed_statuses_group" =
  [%test_eq: string]
    (Status.expand_renamed_paths "test/{bar" "baz}")
    "test/bar => test/baz"

let%test_unit "expand_renamed_statuses_group_nested" =
  [%test_eq: string]
    (Status.expand_renamed_paths "test/{bar" "a1/baz}")
    "test/bar => test/a1/baz"

let%test_unit "expand_renamed_statuses_parent+suffix" =
  [%test_eq: string]
    (Status.expand_renamed_paths "test/{a" "b}/cook")
    "test/a/cook => test/b/cook"

let%test_unit "expand_renamed_statuses_parent+suffix_empty_first" =
  [%test_eq: string]
    (Status.expand_renamed_paths "test/{" "bar}/baz")
    "test/baz => test/bar/baz"

let%test_unit "expand_renamed_statuses_parent+suffix_empty_second" =
  [%test_eq: string]
    (Status.expand_renamed_paths "test/{bar" "}/baz")
    "test/bar/baz => test/baz"

(* parse_diff_details *)

let%test_unit "parse_diff_details_simple" =
  [%test_eq: Status.diff_details option]
    (Status.parse_diff_details "pancake                |   4 ++--")
    (Some { file = "pancake"; change_count = "4"; signs = "++--" })

let%test_unit "parse_diff_details_rename" =
  [%test_eq: Status.diff_details option]
    (Status.parse_diff_details "test/{st => org/st}    |   2 --")
    (Some { file = "test/st => test/org/st"; change_count = "2"; signs = "--" })

let%test_unit "parse_diff_details_no_signs" =
  [%test_eq: Status.diff_details option]
    (Status.parse_diff_details " test/zbg.ml   | 0")
    (Some { file = "test/zbg.ml"; change_count = "0"; signs = "" })

let%test_unit "parse_diff_details_binary" =
  [%test_eq: Status.diff_details option]
    (Status.parse_diff_details ".pancake.un~           | Bin 0 -> 412 bytes")
    (Some
       { file = ".pancake.un~"; change_count = "Bin"; signs = "0 -> 412 bytes" })
