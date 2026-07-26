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
all u1,u2:User | all p1,p2:Photo|((p1 not in Ad) implies (((u1->p1 in posts) and (u2->u1 in follows)) implies (u2->p1 in sees))) and (all u:User|p2 in Ad implies u->p2 in sees)
}

pred inv3c {
	all p : User | p.sees - Ad in p.follows.posts
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 

