
functor Compile(structure Excon : EXCON
		structure FinMap: FINMAP

		structure Lvars : LVARS
		structure LambdaExp: LAMBDA_EXP
		  sharing type LambdaExp.lvar = Lvars.lvar

	        structure LambdaStatSem : LAMBDA_STAT_SEM
		  sharing type LambdaStatSem.LambdaPgm = LambdaExp.LambdaPgm

	        structure EliminateEq : ELIMINATE_EQ 
		  sharing type EliminateEq.LambdaPgm = LambdaExp.LambdaPgm

                structure RType : RTYPE

                structure RegionExp: REGION_EXP

		structure Effect: EFFECT
		  sharing type Effect.effect = RegionExp.effect

                structure SpreadExp: SPREAD_EXPRESSION
		  sharing SpreadExp.E = LambdaExp
		      and SpreadExp.E' = RegionExp
                      and type SpreadExp.place = Effect.effect = Effect.effect
                      and type SpreadExp.cone = Effect.cone = SpreadExp.RegionStatEnv.cone
		      and type SpreadExp.RegionStatEnv.TypeAndPlaceScheme = RegionExp.sigma
		      and type SpreadExp.RegionStatEnv.excon = RegionExp.excon
		      and type SpreadExp.RegionStatEnv.lvar = RegionExp.lvar
		      and type SpreadExp.RegionStatEnv.place = RegionExp.place
		      and type SpreadExp.RegionStatEnv.Type = RegionExp.Type

                structure RegInf: REGINF
		  sharing type RegInf.cone = Effect.cone
		      and type RegInf.rse = SpreadExp.RegionStatEnv.regionStatEnv
		      and type RegInf.trip = RegionExp.trip
		      and type RegInf.place = RType.place = SpreadExp.place = RegionExp.place

		structure Mul: MUL
		structure MulInf: MUL_INF
		  sharing type MulInf.place = Effect.place
		      and type MulInf.cone = RegInf.cone
		      and type MulInf.efenv = Mul.efenv
		      and type MulInf.mularefmap = Mul.mularefmap (*Psi*)
		      and type MulInf.LambdaPgm_phi = RegionExp.LambdaPgm

		structure MulExp: MUL_EXP
		  sharing type MulInf.LambdaPgm_psi = MulExp.LambdaPgm
		      and type MulExp.place = MulInf.place
		      and type MulExp.mul = MulInf.mul
                      and type MulExp.regionStatEnv= SpreadExp.RegionStatEnv.regionStatEnv

		structure AtInf: AT_INF
		  sharing type AtInf.LambdaPgm = MulExp.LambdaPgm
		      and type AtInf.place = Effect.place
		      and type AtInf.mul = MulExp.mul
		      and type AtInf.qmularefset = MulInf.qmularefset = MulExp.qmularefset
			      
		structure DropRegions: DROP_REGIONS
		  sharing type DropRegions.at = AtInf.at
		      and type DropRegions.place = Effect.place
		      and type DropRegions.mul = MulExp.mul
		      and type DropRegions.LambdaPgm = MulExp.LambdaPgm

		structure PhysSizeInf : PHYS_SIZE_INF
		  sharing type PhysSizeInf.at = AtInf.at
		      and type PhysSizeInf.place = Effect.place
		      and type PhysSizeInf.LambdaPgm = MulExp.LambdaPgm
		      and type PhysSizeInf.mul = MulExp.mul

		structure RegionFlowGraphProfiling : REGION_FLOW_GRAPH_PROFILING
		sharing type RegionFlowGraphProfiling.place = PhysSizeInf.place
		    and type RegionFlowGraphProfiling.at = AtInf.at
		    and type RegionFlowGraphProfiling.phsize = PhysSizeInf.phsize
		    and type RegionFlowGraphProfiling.pp = PhysSizeInf.pp

		structure CompLamb : COMP_LAMB
		  sharing type CompLamb.at = AtInf.at
		      and type CompLamb.LambdaPgm = PhysSizeInf.LambdaPgm
		      and type CompLamb.place = PhysSizeInf.place
		      and type CompLamb.phsize = PhysSizeInf.phsize
		      and type CompLamb.pp = PhysSizeInf.pp

		structure CompilerEnv: COMPILER_ENV
		  sharing type CompilerEnv.lvar = LambdaExp.lvar
                      and type CompilerEnv.excon = LambdaExp.excon = Excon.excon
                      and type CompilerEnv.Type = LambdaExp.Type

                structure CompileDec: COMPILE_DEC
		  sharing type CompileDec.LambdaPgm = LambdaExp.LambdaPgm
                      and type CompileDec.CEnv = CompilerEnv.CEnv

                structure OptLambda: OPT_LAMBDA
		  sharing type OptLambda.LambdaPgm = LambdaExp.LambdaPgm

                structure KAMBackend : KAM_BACKEND
		  sharing type CompLamb.EA = KAMBackend.EA
		      and type CompLamb.code = KAMBackend.code

		structure CompileBasis: COMPILE_BASIS
		  sharing type CompileBasis.EqEnv = EliminateEq.env
		      and type CompileBasis.OEnv = OptLambda.env
		      and type CompileBasis.TCEnv = LambdaStatSem.env 
                      and type CompileBasis.rse = SpreadExp.RegionStatEnv.regionStatEnv
		      and type CompileBasis.drop_env = DropRegions.env
		      and type CompileBasis.psi_env = PhysSizeInf.env
                      and type CompileBasis.l2kam_ce = CompLamb.env 
	       	      and type CompileBasis.mulenv = MulInf.efenv
                      and type CompileBasis.mularefmap = MulInf.mularefmap

                structure Report: REPORT
		structure Flags: FLAGS

		structure PP: PRETTYPRINT
		  sharing type CompileBasis.StringTree
                                     = LambdaExp.StringTree
			             = EliminateEq.StringTree
                                     = CompilerEnv.StringTree
                                     = PP.StringTree
                                     = SpreadExp.RegionStatEnv.StringTree
                                     = Effect.StringTree
                                     = RegionExp.StringTree
                                     = MulExp.StringTree
                                     = MulInf.StringTree
			             = AtInf.StringTree
			             = PhysSizeInf.StringTree
		                     = RegionFlowGraphProfiling.StringTree
                      and type PP.Report = Report.Report
			
	        structure Name : NAME

                structure Crash: CRASH
		structure Timing: TIMING
		  ): COMPILE =

  struct

    structure List = Edlib.List

    structure CE = CompilerEnv

    type CompileBasis = CompileBasis.CompileBasis
    type CEnv = CompilerEnv.CEnv
    type strdec = CompileDec.strdec
    type EA = KAMBackend.EA
    type linkinfo = {code_label:KAMBackend.EA, imports: EA list, exports : EA list, unsafe:bool}
    fun code_label_of_linkinfo (li:linkinfo) = #code_label li
    fun exports_of_linkinfo (li:linkinfo) = #exports li
    fun imports_of_linkinfo (li:linkinfo) = #imports li
    fun unsafe_linkinfo (li:linkinfo) = #unsafe li
    val pp_EA = KAMBackend.KAM.pp_EA

    fun die s = Crash.impossible ("Compile." ^ s)

    (* ---------------------------------------------------------------------- *)
    (*  Dynamic Flags.                                                        *)
    (* ---------------------------------------------------------------------- *)

    val print_opt_lambda_expression = ref false
    val print_drop_regions_expression_with_storage_modes = ref false 
    val _ = Flags.add_flag_to_menu (["Printing of intermediate forms"], "print_opt_lambda_expression",
				    "print optimised lambda expression", print_opt_lambda_expression)
    val _ = Flags.add_flag_to_menu (["Printing of intermediate forms"], 
				    "print_drop_regions_expression_with_storage_modes",
				    "print drop regions expression with storage modes", 
				    print_drop_regions_expression_with_storage_modes)

    val print_physical_size_inference_expression =
          Flags.lookup_flag_entry "print_physical_size_inference_expression"
    val print_call_explicit_expression =
          Flags.lookup_flag_entry "print_call_explicit_expression"
    val print_program_points = Flags.lookup_flag_entry "print_program_points"


    (* ---------------------------------------------------------------------- *)
    (*  Printing utilities                                                    *)
    (* ---------------------------------------------------------------------- *)

    fun out_layer (stl:PP.StringTree list) =
      PP.outputTree((fn s => TextIO.output(TextIO.stdOut, s)), 
         PP.NODE{start = "[", finish = "]", childsep = PP.RIGHT ",", indent = 1, 
                 children = stl}, !Flags.colwidth)

    fun pr0 st log = (Report.print' (PP.reportStringTree st) log; 
                      TextIO.flushOut log)
    fun pr st = pr0 st (!Flags.log)

    fun length l = List.foldR (fn _ => fn n => n+1) 0 l

    fun msg(s: string) = (TextIO.output(!Flags.log, s); TextIO.flushOut (!Flags.log)
			  (*; TextIO.output(TextIO.stdOut, s)*))

    fun chat(s: string) = if !Flags.chat then msg s else ()

    fun fast_pr stringtree = 
           (PP.outputTree ((fn s => TextIO.output(!Flags.log, s)) , stringtree, !Flags.colwidth);
            TextIO.output(!Flags.log, "\n"))

    fun display(title, tree) =
        fast_pr(PP.NODE{start=title ^ ": ",
                   finish="",
                   indent=3,
                   children=[tree],
                   childsep=PP.NOSEP
                  }
          )

    fun ifthen e f = if e then f() else ()
    fun footnote(x, y) = x
    infix footnote

    fun printCEnv ce =
      ifthen (!Flags.DEBUG_COMPILER)
      (fn _ => display("CompileAndRun.CEnv", CompilerEnv.layoutCEnv ce))


    (* ---------------------------------------------------------------------- *)
    (*  Abbreviations                                                         *)
    (* ---------------------------------------------------------------------- *)
      
    val layoutLambdaPgm = LambdaExp.layoutLambdaPgm 
    fun layoutRegionPgm  x = (RegionExp.layoutLambdaPgm 
                            (if !Flags.print_regions then (fn rho => SOME(PP.LEAF("at " ^ PP.flatten1(Effect.layout_effect rho))))
                             else fn _ => NONE)
                            (fn _ => NONE)) x
    fun layoutRegionExp x = (RegionExp.layoutLambdaExp 
                            (if !Flags.print_regions then (fn rho => SOME(PP.LEAF("at " ^ PP.flatten1(Effect.layout_effect rho))))
                             else fn _ => NONE)
                             (fn _ => NONE)) x

    fun say x = TextIO.output(!Flags.log, x)
    fun sayenv rse = PP.outputTree(say, SpreadExp.RegionStatEnv.layout rse, !Flags.colwidth)

    type arity = int


    (* -----------------------------------------
     * Effect `recounter'; for normalisation
     * ----------------------------------------- *)

    local 
      val effect_init = ref 6   (* there are six free variables (global_regions) in init_rse. *)
      val effect_count = ref (!effect_init)
    in
      fun effect_counter() = (effect_count := !effect_count + 1; !effect_count)
      fun reset_effect_count() = effect_count := !effect_init
      fun commit_effect_count() = effect_init := !effect_count
    end


    (* --------------------------------------------
     * Program point counter
     * -------------------------------------------- *)

    local 
      val pp_init = ref 1   (* ~1 and 0 are reserved *)
      val pp_count = ref (!pp_init)
    in
      fun pp_counter() = (pp_count := !pp_count + 1; !pp_count)
      fun reset_pp_count() = pp_count := !pp_init
      fun commit_pp_count() = pp_init := !pp_count
    end


    (* ---------------------------------------------------------------------- *)
    (*  Compile RESET                                                         *)
    (* ---------------------------------------------------------------------- *)
    fun reset () = (CompLamb.reset();
		    LambdaExp.reset();
		    reset_pp_count();
		    reset_effect_count();
                    Effect.reset();       (* resets global cone *)
		    CompileDec.reset())

    fun commit () = (CompLamb.commit();
		     commit_pp_count();
		     LambdaExp.commit();
		     commit_effect_count();
		     Effect.commit())
		     

    (* ---------------------------------------------------------------------- *)
    (*  Compile the declaration using old compiler environment, ce            *)
    (* ---------------------------------------------------------------------- *)

    fun ast2lambda(ce, strdecs) =
      (ifthen (!Flags.chat) (fn _ => msg("\nCompiling abstract syntax tree into lambda language ..."));
       Timing.timing_begin();
       let val _ = LambdaExp.reset()  (* Reset type variable counter to improve pretty printing; The generated
				       * Lambda programs are closed w.r.t. type variables, because code 
				       * generation of the strdecs is done after an entire top-level 
				       * declaration is elaborated. ME 1998-09-04 *)
	   val (ce1, lamb) =  Timing.timing_end_res 
	        ("To lamb", CompileDec.compileStrdecs ce strdecs)
	   val declared_lvars = CompilerEnv.lvarsOfCEnv ce1
	   val declared_excons = CompilerEnv.exconsOfCEnv ce1
       in  
	 ifthen (!Flags.DEBUG_COMPILER) (fn _ => display("Report: UnOpt", layoutLambdaPgm lamb));
	 (lamb,ce1, declared_lvars, declared_excons) 
     end)

    (* ------------------------------------ *)
    (* isEmptyLambdaPgm lamb  returns true  *)
    (* if lamb is a pair of an empty list   *)
    (* of datatype bindings and an empty    *)
    (* frame. Then we need not generate any *)
    (* code.                                *)
    (* ------------------------------------ *)
    fun isEmptyLambdaPgm lamb =
      let open LambdaExp
      in case lamb
	   of PGM(DATBINDS [[]], FRAME {declared_lvars=[], declared_excons=[]}) => true
	    | PGM(DATBINDS [], FRAME {declared_lvars=[], declared_excons=[]}) => true
	    | _ => false
      end

    (* ---------------------------------------------------------------------- *)
    (*  Type check the lambda code                                             *)
    (* ---------------------------------------------------------------------- *)

    fun type_check_lambda (a,b) =
      if Flags.is_on "type_check_lambda" then
	(chat "\nType checking lambda term begin ...\n";
	 Timing.timing_begin();
	 let 
	   val env' = Timing.timing_end_res ("Check lam.",(LambdaStatSem.type_check {env = a,  letrec_polymorphism_only = false,
                  pgm =  b}))
	 in
	   chat "\nType checking lambda term end ...\n";
	   env'
	 end)
      else LambdaStatSem.empty


    (* ---------------------------------------------------------------------- *)
    (*   Eliminate polymorphic equality in the lambda code                    *)
    (* ---------------------------------------------------------------------- *)

    fun elim_eq_lambda (env,lamb) =
      if Flags.is_on "eliminate_polymorphic_equality" then
	(chat "\nEliminating polymorphic equality begin ...\n";
	 Timing.timing_begin();
	 let val (lamb', env') = 
	   Timing.timing_end_res ("Elim. eq.", EliminateEq.elim_eq (env, lamb))
	 in
	   chat "\nEliminating polymorphic equality end ...\n";
	   if !Flags.DEBUG_COMPILER then 
	     (display("Lambda Program After Elimination of Pol. Eq.", 
		      layoutLambdaPgm lamb');
	      display("Pol. Eq. Environment", EliminateEq.layout_env env'))
	   else ();
	   (lamb', env')
	 end)
      else (lamb, EliminateEq.empty)


    (* ---------------------------------------------------------------------- *)
    (*   Optimise the lambda code                                             *)
    (* ---------------------------------------------------------------------- *)

    fun optlambda (env, lamb) =
          (if !Flags.chat then 
             msg (if !Flags.optimiser
		  then "\nOptimising lambda term ..."
		  else "\nRewriting lambda term ...")
	   else ();
	   Timing.timing_begin();
	   let 
	     val (lamb_opt, env') = 
	           Timing.timing_end_res ("Opt. lam.", OptLambda.optimise(env,lamb))
	   in
	     if !Flags.DEBUG_COMPILER orelse !print_opt_lambda_expression
	     then display("Report: Opt", layoutLambdaPgm lamb_opt) else () ;
	     (lamb_opt, env')
	   end)

    (* ---------------------------------------------------------------------- *)
    (*   Spread the optimised lambda code                                     *)
    (* ---------------------------------------------------------------------- *)

    fun spread(cone,rse, lamb_opt)=
        (chat "\nSpreading regions and effects ...";
         Timing.timing_begin();
         (*Profile.reset();
         Profile.profileOn();*)
         let val (cone,rse_con,spread_lamb) = SpreadExp.spreadPgm(cone,rse, lamb_opt)
         in Timing.timing_end("Spread exp.");
            (*Profile.profileOff();
            TextIO.output(!Flags.log, "\n PROFILING OF S\n\n");
            Profile.report(!Flags.log);*)
            if !Flags.DEBUG_COMPILER 
            then (display("\nReport: Spread; program", layoutRegionPgm spread_lamb) ;
                  display("\nReport: Spread; entire cone after Spreading", Effect.layoutCone cone) )
            else ();
            
            (cone,rse_con, spread_lamb)
         end) 


    (* ---------------------------------------------------------------------- *)
    (*   Do the region inference on the spread optimised lambda code          *)
    (* ---------------------------------------------------------------------- *)

    fun inferRegions(cone,rse, rse_con,  spread_lamb as RegionExp.PGM 
                        {expression = spread_lamb_exp,
                         export_datbinds = datbinds,
                         export_basis=export_basis  (* list of region variables and arrow effects *)
                        }) = 
    let
        val _ = (chat "\nInferring regions and effects ...";
		 Timing.timing_begin()
                 (*;Compiler.Profile.reset()
                 ;Compiler.Profile.setTimingMode true*))
        val rse_with_con = SpreadExp.RegionStatEnv.plus(rse,rse_con)
(*	val _ = print "RegInf.inferEffects begin... \n" *)
        val cone = RegInf.inferEffects
                   (fn s => (TextIO.output(!Flags.log, s); TextIO.flushOut(!Flags.log)))
                   (cone,rse_with_con, spread_lamb_exp)
(*	val _ = print "RegInf.inferEffects end.\n"*)
        val new_layer = Effect.topLayer cone (* to get back to level of "cone" *)
(*
        val _ = print "new_layer before lowering:\n"
        val _ = out_layer(Effect.layoutEtas new_layer)
*)
	val toplevel = Effect.level Effect.initCone
	val cone = List.foldL (fn effect => fn cone =>
			       Effect.lower toplevel effect cone) cone new_layer

(*        val _ = print "new_layer after lowering:\n"
        val _ = out_layer(Effect.layoutEtas new_layer)
	val _ = print "\n*** Unifying toplevel regions and effects ***\n" 
*)
        val cone = Effect.unify_with_toplevel_rhos_eps(cone,new_layer)
(*	val _ = print "\n*** Unified toplevel regions and effects ***\n" *)
	val new_layer = []

        val _ = Timing.timing_end("Reg. Inf.")
     (*   val _ = (Profile.profileOff();
                TextIO.output(!Flags.log, "\n PROFILING OF R\n\n");
                Profile.report(!Flags.log));
     *)

        val pgm' = RegionExp.PGM{expression = spread_lamb_exp, (*side-effected*)
                      export_datbinds = datbinds, (*unchanged*)
                      export_basis= new_layer  (* list of region variables and arrow effects *)}

	(* call of normPgm no longer commented out; mads *)
        val _ = if Flags.is_on "region_profiling" then
	          ()
		else
		  (reset_effect_count();      (* inserted; mads *)
		   RegionExp.normPgm(pgm',effect_counter) 
		   )

	val rse' =
	  case spread_lamb_exp
	    of RegionExp.TR(_,RegionExp.Frame{declared_lvars,declared_excons},_) =>
	      (let val rse_temp = 
		 List.foldL (fn {lvar,compound,create_region_record,sigma, place} => fn rse =>
			     SpreadExp.RegionStatEnv.declareLvar(lvar,(compound, 
							   create_region_record, !sigma, place, 
							   SOME(ref[]) (* reset occurrences *), NONE
							 ), rse)) rse_con declared_lvars
	       in
		 List.foldL (fn (excon, SOME(Type, place)) => (fn rse =>
							       SpreadExp.RegionStatEnv.declareExcon(excon,(Type,place),rse))
			      | _ => die "rse.excon") rse_temp declared_excons

	       end handle _ => die "cannot form rse'")
	     | _ => die "program does not have type frame"
    in 
      if !Flags.DEBUG_COMPILER then
        (say "Resulting region-static environment:\n";
	 sayenv(rse');
	 display("\nReport: After Region Inference", layoutRegionPgm pgm'))
      else ();
      (cone,rse',pgm')       (* rse' contains rse_con *)
    end

    (* ---------------------------------------------------------------------- *)
    (*   Multiplicity Inference                                               *)
    (* ---------------------------------------------------------------------- *)

    fun mulInf(program_after_R:(Effect.place,unit)RegionExp.LambdaPgm, Psi, cone, mulenv) =
    let

        val _ = (chat "\nInferring multiplicities ...";
                Timing.timing_begin()
                (*;Profile.reset()
                ;Profile.profileOn()*) )
        val (pgm', mulenv',Psi') = MulInf.mulInf(program_after_R,Psi,cone,mulenv)

        val _ = Timing.timing_end("Multiplicity Inference")

(*        val _ = ( Profile.profileOff()(*;
                TextIO.output(!Flags.log, "\n PROFILING OF MulInf\n\n");
                Profile.report(!Flags.log)*));
*)
    in 
        if !Flags.DEBUG_COMPILER 
            then (display("\nReport: After Multiplicity Inference, the program is:\n",
                   	    MulInf.layoutLambdaPgm pgm'))
            else ();

        (pgm', mulenv', Psi')
    end
    


    (* ---------------------------------------------------------------------- *)
    (*  Spread Expression, Region Inference and Multiplicity Inference        *)
    (* We now connect the three phases above. No cone is needed in the        *)
    (* compiler (dynamic) basis. Instead, a cone is built from the initial    *)
    (* rse, and lives throughout all three phases. All generated, free nodes  *)
    (* of a lambda program are lowered to have level toplevel; i.e. 1.        *)
    (* ---------------------------------------------------------------------- *)

    fun SpreadRegMul(rse, Psi, mulenv, opt_pgm) =
      let val cone = Effect.push (SpreadExp.RegionStatEnv.mkConeToplevel rse)
	  val (cone, rse_con, spread_pgm) = spread(cone,rse,opt_pgm)
	  val (cone, rse', reginf_pgm) = inferRegions(cone,rse,rse_con,spread_pgm)
	  val (mul_pgm, mulenv', Psi') = mulInf(reginf_pgm,Psi,cone,mulenv)
      in (mul_pgm, rse', mulenv', Psi')
      end


    (* ---------------------------------------------------------------------- *)
    (*   Perform K-normalisation                                              *)
    (* ---------------------------------------------------------------------- *)

    local open MulInf
    in fun k_norm(pgm: (place,place*mul,qmularefset ref)LambdaPgm_psi) 
	: (place,place*mul,qmularefset ref)LambdaPgm_psi =
	(chat "\nK-normalisation ...\n";
         Timing.timing_begin();
         let val pgm' = MulInf.k_normPgm pgm
	 in Timing.timing_end("K-norm");
(*KILL 29/03/1997 19:29. tho.:
	    if Flags.is_on "print_K_normal_forms" 
               orelse !Flags.DEBUG_COMPILER then 
	      display("\nReport: K-normalised program:", layoutLambdaPgm pgm')
	    else ();
*)
	    pgm'
	 end)
    end	

    (* ---------------------------------------------------------------------- *)
    (*   Do attop/atbot analysis                                              *)
    (* ---------------------------------------------------------------------- *)

    local open AtInf
    in fun storagemodeanalysis(pgm: (place,place*mul,qmularefset ref)LambdaPgm) 
	: (place at,place*mul,unit)LambdaPgm =
         (* chatting and timing done in AtInf*)
	 let val pgm' = sma pgm
	 in 
	    if Flags.is_on "print_attop_atbot_expression" 
               orelse !Flags.DEBUG_COMPILER then 
	          display("\nReport: ATTOP/ATBOT:", layout_pgm pgm')
	    else ();
	    pgm'
	 end
    end	


    (* ---------------------------------------------------------------------- *)
    (*   Do drop regions                                                      *)
    (* ---------------------------------------------------------------------- *)
  
    local open DropRegions
    in
      val drop_regions : env*(place at,place*mul,unit)LambdaPgm -> (place at,place*mul,unit)LambdaPgm * env =
	fn (env, pgm) =>
	(chat "\nDrop Regions ...\n";
         Timing.timing_begin();
         let val (pgm',env') = drop_regions(env, pgm)
	 in Timing.timing_end("Drop");
	    if Flags.is_on "print_drop_regions_expression" then 
	      display("\nReport: AFTER DROP REGIONS:", AtInf.layout_pgm_brief pgm')
	    else ();
	    if Flags.is_on "print_drop_regions_expression_with_storage_modes" orelse !Flags.DEBUG_COMPILER then 
	      display("\nReport: AFTER DROP REGIONS (with storage modes):", AtInf.layout_pgm pgm')
	    else ();
	    (pgm',env')
	 end)
    end


    (* ---------------------------------------------------------------------- *)
    (*   Do physical size inference                                           *)
    (* ---------------------------------------------------------------------- *)
  
    local open PhysSizeInf
   in
      fun phys_size_inf (env: env, pgm:(place at,place*mul,unit)LambdaPgm) 
	: ((place*pp)at,place*phsize,unit)LambdaPgm * env =
	(chat "\nPhysical Size Inference ...\n";
         Timing.timing_begin();
         let val (pgm',env') = psi(pp_counter, env, pgm)
	 in Timing.timing_end("PSI");
	    if !print_physical_size_inference_expression orelse !Flags.DEBUG_COMPILER then 
	      display("\nReport: AFTER PHYSICAL SIZE INFERENCE:", layout_pgm pgm')
	    else ();
	    (pgm',env')
	 end)
    end


    (* ---------------------------------------------------------------------- *)
    (*   Warn against dangling pointers (when Garbage Collection is on)       *)
    (* ---------------------------------------------------------------------- *)

       fun warn_dangling_pointers(rse, psi_pgm) = 
        let (* warn against dangling references *)
            fun get_place_at(AtInf.ATTOP(rho,pp)) = rho
              | get_place_at(AtInf.ATBOT(rho,pp)) = rho
              | get_place_at(AtInf.SAT(rho,pp)) = rho
              | get_place_at(AtInf.IGNORE) = Effect.toplevel_region_withtype_top
        in
            chat "\nChecking whether there are dangling pointers ...";
            Timing.timing_begin();
            MulExp.warn_dangling_pointers(rse, psi_pgm, get_place_at);
            Timing.timing_end("Dangle")
        end


    (* ---------------------------------------------------------------------- *)
    (*   Do application conversion                                            *)
    (* ---------------------------------------------------------------------- *)
  
    local open PhysSizeInf
    in
      fun appConvert (pgm:((place*pp)at,place*phsize,unit)LambdaPgm): 
                          ((place*pp)at,place*phsize,unit)LambdaPgm =
	(chat "\nApplication Conversion ...\n";
         Timing.timing_begin();
         let val pgm' = PhysSizeInf.appConvert(pgm)
	 in Timing.timing_end("App Conv");
	    if !print_call_explicit_expression orelse !Flags.DEBUG_COMPILER then 
	      display("\nReport: AFTER APPLICATION CONVERSION:", layout_pgm pgm')
	    else ();
	    pgm'
	 end)
    end

    (* ---------------------------------------------------------------------- *)
    (*   Compile region annotated code to KAM code                            *)
    (* ---------------------------------------------------------------------- *)
    fun comp_lamb(l2kam_ce, pgm) = 
      let val _ = chat "\nCompiling region annotated lambda language ..."
	  val _ = Timing.timing_begin()
	  val {code_label, code, env=l2kam_ce1,imports,exports} = CompLamb.comp_lamb(l2kam_ce, pgm)
	  val _ = Timing.timing_end("Com. Lam.")
      in {code_label=code_label, code=code, l2kam_ce1=l2kam_ce1, imports=imports,exports=exports}
      end


    (* ===================================
     * Compile with the NEW backend
     * =================================== *)

    type target = KAMBackend.target
    fun comp_with_new_backend(rse, Psi, mulenv, drop_env, psi_env, l2kam_ce, lamb_opt, vcg_file) =
      let
	val unsafe = not(LambdaExp.safeLambdaPgm lamb_opt)
	val (mul_pgm, rse1, mulenv1, Psi1) = SpreadRegMul(rse, Psi, mulenv, lamb_opt)
        val _ = MulExp.warn_puts(rse, mul_pgm)
        val k_mul_pgm = k_norm mul_pgm
	val sma_pgm = storagemodeanalysis k_mul_pgm
	val (drop_pgm, drop_env1) = drop_regions(drop_env,sma_pgm)
	val (psi_pgm, psi_env1) = phys_size_inf(psi_env, drop_pgm)
        val _ = warn_dangling_pointers(rse, psi_pgm)
        val app_conv_psi_pgm = appConvert psi_pgm
	val _ = RegionFlowGraphProfiling.reset_graph ()
	val {code_label,l2kam_ce1, code, exports, imports} = comp_lamb(l2kam_ce, app_conv_psi_pgm) 

	(* Generate lambda code file with program points *)
	val old_setting = !print_program_points
	val _ = print_program_points := true
	val old_setting2 = !Flags.print_regions
	val _ = Flags.print_regions := true
	val _ = 
	  if Flags.is_on "generate_lambda_code_with_program_points" then
	    (display("\nReport: LAMBDA CODE WITH PROGRAM POINTS:", PhysSizeInf.layout_pgm psi_pgm);
	     display("\nReport: REGION FLOW GRAPH FOR PROFILING:", RegionFlowGraphProfiling.layout_graph()))
	  else ()
	val _ = print_program_points := old_setting
	val _ = Flags.print_regions := old_setting2

	(* Generate VCG graph *)
	val _ = if (Flags.is_on "generate_vcg_graph") then
                  let
	            val outStreamVCG = TextIO.openOut vcg_file
		  in
		    (chat "\nGenerate VCG region flow graph for profiling ...";
		     RegionFlowGraphProfiling.export_graph outStreamVCG;
		     TextIO.closeOut(outStreamVCG))
		  end
		else
		  ()

	val target = KAMBackend.generate_target_code code
	val linkinfo = {code_label=code_label,imports=imports,exports=exports,unsafe=unsafe}
      in
	(rse1, Psi1, mulenv1, drop_env1, psi_env1, l2kam_ce1, target, linkinfo)
      end


    (************************************************************************)
    (* This is the main function; It invokes all the passes of the back end *)
    (************************************************************************)

    datatype res = CodeRes of CEnv * CompileBasis * target * linkinfo
                 | CEnvOnlyRes of CEnv

    fun compile(CEnv, Basis, strdecs, vcg_file) : res =
      let

	(* There is only space in the basis for one lambdastat-env.
	 * If we want more checks, we should insert more components
	 * in bases. For now, we do type checking after optlambda, only. *)

        val _ = RegionExp.printcount:=1;
	val {TCEnv,EqEnv,OEnv,rse,mulenv, mularefmap,drop_env,psi_env,l2kam_ce} =
	  CompileBasis.de_CompileBasis Basis

        val (lamb,CEnv1, declared_lvars, declared_excons) = ast2lambda(CEnv, strdecs)
	val (lamb',EqEnv1) = elim_eq_lambda (EqEnv, lamb)
        val (lamb_opt,OEnv1) = optlambda (OEnv, lamb')
	val TCEnv1 = type_check_lambda (TCEnv, lamb_opt)
      in
	if isEmptyLambdaPgm lamb_opt 
          then (chat "Empty lambda program; skipping code generation.\n";
                CEnvOnlyRes CEnv1)
	else
	  let val (rse1, mularefmap1, mulenv1, drop_env1, psi_env1, l2kam_ce1, target, linkinfo) = 
	       comp_with_new_backend(rse, mularefmap, mulenv, drop_env, psi_env, l2kam_ce, lamb_opt, vcg_file)
	      val Basis' = CompileBasis.mk_CompileBasis {TCEnv=TCEnv1,EqEnv=EqEnv1,OEnv=OEnv1,
							 rse=rse1,mulenv=mulenv1,mularefmap=mularefmap1,
							 drop_env=drop_env1,psi_env=psi_env1,l2kam_ce=l2kam_ce1}
	  in CodeRes (CEnv1, Basis', target, linkinfo)
	  end
      end

    val generate_link_code = 
      let
	(* Global regions for all modules. *)
	val basis_info : (int*EA) list = 
	  [(Effect.key_of_eps_or_rho Effect.toplevel_region_withtype_top, KAMBackend.KAM.toplevel_region_withtype_topEA),
	   (Effect.key_of_eps_or_rho Effect.toplevel_region_withtype_string, KAMBackend.KAM.toplevel_region_withtype_stringEA),
	   (Effect.key_of_eps_or_rho Effect.toplevel_region_withtype_real, KAMBackend.KAM.toplevel_region_withtype_realEA)]
      in
	KAMBackend.generate_link_code basis_info
      end
    val emit = KAMBackend.emit


  end;
