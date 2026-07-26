sig User {
	follows : set User,
	sees : set Photo,
	posts : set Photo,
	suggested : set User
}

sig Influencer extends User {}

sig Photo {
	date : one Day
}
sig Ad extends Photo {}

sig Day {}

pred inv3 {
(all ref0:(one User),ref1:(one Photo)|(((ref1 in (ref0 . (User <: sees))) => ((ref1 . (~ (User <: posts))) in (ref0 . (User <: follows)))) || (ref1 in Ad)))
}

pred inv3c {
	all p : User | p.sees - Ad in p.follows.posts
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 

