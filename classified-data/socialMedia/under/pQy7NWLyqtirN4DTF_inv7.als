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

pred inv7 {
all disj x, y, z: User | x->y in follows and y->z in follows and x->z not in follows implies x->z in suggested
all disj x, z : User| x->z in suggested implies x->z not in follows and some y: User | x->y in follows and y->z in follows
}

pred inv7c {
	all u : User | u.suggested = u.follows.follows - u.follows - u
}

check correct { inv7 <=> inv7c}
pred under { inv7 and !inv7c}
pred over { !inv7 and inv7c}
run over 
run under 

