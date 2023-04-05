open Base
open Zbg

(* String utils *)

let%test_unit "unlines_one_string" =
  [%test_eq: string] (Extended_string.unlines ["line 1"]) "line 1"

let%test_unit "unlines_two_strings" =
  [%test_eq: string] (Extended_string.unlines ["line 1"; "line 2"]) "line 1\nline 2"

let%test_unit "unwords_two_words" =
  [%test_eq: string] (Extended_string.unwords ["word1"; "word2"]) "word1 word2"

let%test_unit "wording_two_words" =
  [%test_eq: string list] (Extended_string.words "word1 word2") ["word1"; "word2"]

let%test_unit "justify_left" =
  [%test_eq: string] (Extended_string.justify_left 7 "0123") "0123   "

let%test_unit "justify_right" =
  [%test_eq: string] (Extended_string.justify_right 7 "0123") "   0123"