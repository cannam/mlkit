(* Type variables - Definition v3 page ?? *)

(*$TyVar: CRASH TYVAR*)
functor TyVar(structure Crash: CRASH): TYVAR =
  struct
    datatype SyntaxTyVar = TYVAR of string

    val mk_TyVar = TYVAR
    fun pr_tyvar(TYVAR str) = str

(*KILL 23/06/1997 15:33. tho.:
    local
      fun snd(TYVAR str) =
	StringListOps.nth 1 str
        handle StringListOps.Subscript _ => Crash.impossible "TyVar.snd"
    in
      fun isEquality tv = (snd tv = "'")
    end
*)
    fun isEquality (TYVAR s) = (case explode s of
				  "'" :: "'" :: ss => true
				| _ => false)
  end;
