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
(all u1,u2:User | all p:Photo | p not in Ad implies (u1->u2 in follows and u2->p in posts and u1->p in sees))
and
(all u3 : User | all p2 : Photo | p2 in Ad implies u3->p2 in sees)
}

pred inv3c {
	all p : User | p.sees - Ad in p.follows.posts
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 

