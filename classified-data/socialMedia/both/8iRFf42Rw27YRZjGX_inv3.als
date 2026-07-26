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
(all a: Ad | all u: User | u->a in sees)
(all p: Photo-Ad | all u1, u2: User | (u1->p in sees and u2->p in posts) implies u1->u2 in follows)
(all u : User | all p: Photo | u->p in posts implies u->p not in sees)
}

pred inv3c {
	all p : User | p.sees - Ad in p.follows.posts
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 

