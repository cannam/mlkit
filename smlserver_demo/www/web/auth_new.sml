structure FV = FormVar
val email = FV.wrapFail FV.getEmailErr ("email", "Email")
val name = FV.wrapFail FV.getStringErr ("name", "Name")
val url = FV.wrapFail FV.getUrlErr ("url", "Home page URL")

val passwd = Auth.newPassword 6

val ins =
  `insert into person (person_id, email, 
		       name, url, password)
   values (^(Db.seqNextvalExp "person_seq"),
	   ^(Db.qqq email),
	   ^(Db.qqq name),
	   ^(Db.qqq url),
	   ^(Db.qqq passwd))`

val _ = Db.dml ins
  handle _ =>
    (Page.return "Already member"
     `The email address ^email is already in the
     database - you may have the system 
     <a href="auth_send.sml?email=^(Web.encodeUrl 
     email)">send your password by email</a>.`
     ; Web.exit())

val _ = Web.returnRedirect 
  ("auth_send.sml?email=" ^ Web.encodeUrl email)
  
