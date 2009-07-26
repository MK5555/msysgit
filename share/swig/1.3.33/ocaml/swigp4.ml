open Pcaml ;;

let lap x y = x :: y
let c_ify e  = 	  
  match e with
      <:expr< $int:_$ >> -> <:expr< (C_int $e$) >>
    | <:expr< $str:_$ >> -> <:expr< (C_string $e$) >>
    | <:expr< $chr:_$ >> -> <:expr< (C_char $e$) >>
    | <:expr< $flo:_$ >> -> <:expr< (C_double $e$) >>
    | <:expr< True    >> -> <:expr< (C_bool $e$) >>
    | <:expr< False   >> -> <:expr< (C_bool $e$) >>
    | _ -> <:expr< $e$ >>
let mk_list args  f =
  let rec mk_list_inner args  f =
    match args with
	[] -> <:expr< [] >>
      | x :: xs ->
	  (let  = MLast.loc_of_expr x in
	     <:expr< [ ($f x $) ] @ ($mk_list_inner xs  f$) >>) in
    match args with
	[] -> <:expr< (Obj.magic C_void) >>
      | [ a ] -> <:expr< (Obj.magic $f a $) >>
      | _ -> <:expr< (Obj.magic (C_list ($mk_list_inner args  f$))) >>

EXTEND
  expr:
  [ [ e1 = expr ; "'" ; "[" ; e2 = expr ; "]" ->
	<:expr< (invoke $e1$) "[]" (C_list [ $c_ify e2 $ ]) >>
    | e1 = expr ; "->" ; l = LIDENT ; "(" ; args = LIST0 (expr LEVEL "simple") SEP "," ; ")" ->
	<:expr< (invoke $e1$) $str:l$ ($mk_list args  c_ify$) >>
    | e1 = expr ; "->" ; u = UIDENT ; "(" ; args = LIST0 (expr LEVEL "simple") SEP "," ; ")" ->
	<:expr< (invoke $e1$) $str:u$ ($mk_list args  c_ify$) >>
    | e1 = expr ; "->" ; s = expr LEVEL "simple" ; "(" ; args = LIST0 (expr LEVEL "simple") SEP "," ; ")" ->
	<:expr< (invoke $e1$) $s$ ($mk_list args  c_ify$) >>
    | e1 = expr ; "'" ; "." ; "(" ; args = LIST0 (expr LEVEL "simple") SEP "," ; ")" ->
	<:expr< (invoke $e1$) "()" ($mk_list args  c_ify$) >>
    | e1 = expr ; "'" ; "->" ; l = LIDENT ; "(" ; args = LIST0 (expr LEVEL "simple") SEP "," ; ")" ->
	<:expr< (invoke ((invoke $e1$) "->" C_void)) $str:l$ ($mk_list args  c_ify$) >>
    | e1 = expr ; "'" ; "->" ; u = UIDENT ; "(" ; args = LIST0 (expr LEVEL "simple") SEP "," ; ")" ->
	<:expr< (invoke ((invoke $e1$) "->" C_void)) $str:u$ ($mk_list args  c_ify$) >>
    | e1 = expr ; "'" ; "->" ; s = expr LEVEL "simple" ; "(" ; args = LIST0 (expr LEVEL "simple") SEP "," ; ")" ->
	<:expr< (invoke ((invoke $e1$) "->" C_void)) $s$ ($mk_list args  c_ify$) >>
    | e1 = expr ; "'" ; "++" ->
	<:expr< (invoke $e1$) "++" C_void >>
    | e1 = expr ; "'" ; "--" ->
	<:expr< (invoke $e1$) "--" C_void >>
    | e1 = expr ; "'" ; "-" ; e2 = expr ->
	<:expr< (invoke $e1$) "-" (C_list [ $c_ify e2 $ ]) >>
    | e1 = expr ; "'" ; "+" ; e2 = expr -> <:expr< (invoke $e1$) "+" (C_list [ $c_ify e2 $ ])  >> 
    | e1 = expr ; "'" ; "*" ; e2 = expr -> <:expr< (invoke $e1$) "*" (C_list [ $c_ify e2 $ ])  >> 
    | "'" ; "&" ; e1 = expr -> 
	<:expr< (invoke $e1$) "&" C_void >> 
    | "'" ; "!" ; e1 = expr ->
	<:expr< (invoke $e1$) "!" C_void >>
    | "'" ; "~" ; e1 = expr ->
	<:expr< (invoke $e1$) "~" C_void >>
    | e1 = expr ; "'" ; "/" ; e2 = expr ->
	<:expr< (invoke $e1$) "/" (C_list [ $c_ify e2 $ ]) >>
    | e1 = expr ; "'" ; "%" ; e2 = expr ->
	<:expr< (invoke $e1$) "%" (C_list [ $c_ify e2 $ ]) >>
    | e1 = expr ; "'" ; "lsl" ; e2 = expr ->
	<:expr< (invoke $e1$) ("<" ^ "<") (C_list [ $c_ify e2 $ ]) >>
    | e1 = expr ; "'" ; "lsr" ; e2 = expr ->
	<:expr< (invoke $e1$) (">" ^ ">") (C_list [ $c_ify e2 $ ]) >>
    | e1 = expr ; "'" ; "<" ; e2 = expr ->
	<:expr< (invoke $e1$) "<" (C_list [ $c_ify e2 $ ]) >>
    | e1 = expr ; "'" ; "<=" ; e2 = expr ->
	<:expr< (invoke $e1$) "<=" (C_list [ $c_ify e2 $ ]) >>
    | e1 = expr ; "'" ; ">" ; e2 = expr ->
	<:expr< (invoke $e1$) ">" (C_list [ $c_ify e2 $ ]) >>
    | e1 = expr ; "'" ; ">=" ; e2 = expr ->
	<:expr< (invoke $e1$) ">=" (C_list [ $c_ify e2 $ ]) >>
    | e1 = expr ; "'" ; "==" ; e2 = expr ->
	<:expr< (invoke $e1$) "==" (C_list [ $c_ify e2 $ ]) >>
    | e1 = expr ; "'" ; "!=" ; e2 = expr ->
	<:expr< (invoke $e1$) "!=" (C_list [ $c_ify e2 $ ]) >>
    | e1 = expr ; "'" ; "&" ; e2 = expr ->
	<:expr< (invoke $e1$) "&" (C_list [ $c_ify e2 $ ]) >>
    | e1 = expr ; "'" ; "^" ; e2 = expr ->
	<:expr< (invoke $e1$) "^" (C_list [ $c_ify e2 $ ]) >>
    | e1 = expr ; "'" ; "|" ; e2 = expr ->
	<:expr< (invoke $e1$) "|" (C_list [ $c_ify e2 $ ]) >>
    | e1 = expr ; "'" ; "&&" ; e2 = expr ->
	<:expr< (invoke $e1$) "&&" (C_list [ $c_ify e2 $ ]) >>
    | e1 = expr ; "'" ; "||" ; e2 = expr ->
	<:expr< (invoke $e1$) "||" (C_list [ $c_ify e2 $ ]) >>
    | e1 = expr ; "'" ; "=" ; e2 = expr ->
	<:expr< (invoke $e1$) "=" (C_list [ $c_ify e2 $ ]) >>
    | e1 = expr ; "'" ; "+=" ; e2 = expr ->
	<:expr< (invoke $e1$) "+=" (C_list [ $c_ify e2 $ ]) >>
    | e1 = expr ; "'" ; "-=" ; e2 = expr ->
	<:expr< (invoke $e1$) "-=" (C_list [ $c_ify e2 $ ]) >>
    | e1 = expr ; "'" ; "*=" ; e2 = expr ->
	<:expr< (invoke $e1$) "*=" (C_list [ $c_ify e2 $ ]) >>
    | e1 = expr ; "'" ; "/=" ; e2 = expr ->
	<:expr< (invoke $e1$) "/=" (C_list [ $c_ify e2 $ ]) >>
    | e1 = expr ; "'" ; "%=" ; e2 = expr ->
	<:expr< (invoke $e1$) "%=" (C_list [ $c_ify e2 $ ]) >>
    | e1 = expr ; "'" ; "lsl" ; "=" ; e2 = expr ->
	<:expr< (invoke $e1$) ("<" ^ "<=") (C_list [ $c_ify e2 $ ]) >>
    | e1 = expr ; "'" ; "lsr" ; "=" ; e2 = expr ->
	<:expr< (invoke $e1$) (">" ^ ">=") (C_list [ $c_ify e2 $ ]) >>
    | e1 = expr ; "'" ; "&=" ; e2 = expr ->
	<:expr< (invoke $e1$) "&=" (C_list [ $c_ify e2 $ ]) >>
    | e1 = expr ; "'" ; "^=" ; e2 = expr ->
	<:expr< (invoke $e1$) "^=" (C_list [ $c_ify e2 $ ]) >> 
    | e1 = expr ; "'" ; "|=" ; e2 = expr ->
	<:expr< (invoke $e1$) "|=" (C_list [ $c_ify e2 $ ]) >>
    | "'" ; e = expr -> c_ify e 
    | c = expr ; "as" ; id = LIDENT -> <:expr< $lid:"get_" ^ id$ $c$ >>
    | c = expr ; "to" ; id = LIDENT -> <:expr< $uid:"C_" ^ id$ $c$ >>
    | "`" ; "`" ; l = LIDENT -> <:expr< C_enum `$lid:l$ >>
    | "`" ; "`" ; u = UIDENT -> <:expr< C_enum `$uid:u$ >>
    | f = expr ; "'" ; "(" ; args = LIST0 (expr LEVEL "simple") SEP "," ; ")" -> 
	<:expr< $f$ ($mk_list args  c_ify$) >>
    ] ] ;
END ;;
      