functor questionnaire () : SCRIPTLET =
    struct
	open Scripts infix & % attr 

	fun head s = tha (A.align A.left) ($s)
	val radioGroup = radioDrop
	    (tr (head "Male:"  & td(inputRadioa' (A.checked()) questionnaire2.male (Form.Bool true))) &
	     tr (head "Female:" & td(inputRadio questionnaire2.male (Form.Bool false))))

        val response = 
	    Page.page "Please answer the following form" 
	    (questionnaire2.form
	     (swap (Succ(One()))
	      (swap (One())
	     (table (tr (head "Name:" & td(inputText questionnaire2.name NONE)) &
		     tr (head "Email:" & td(inputText questionnaire2.email NONE)) &
		     radioGroup &
		     tr (tda (A.colspan 2)
			 (inputSubmit "Submit information")))))))
    end
