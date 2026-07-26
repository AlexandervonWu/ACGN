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
all u1, u2 : User | all ph : Photo | (ph in u1.posts and ph in u2.sees) implies (u1 in u2.follows and u1 != u2)

all u1, u2 : User | all ph : Photo | some ad : Ad | (ph in u1.sees and ph in u2.posts and u1 not in follows.u2) implies (ph = ad and u1 != u2)

all u1 : User | all ph : Photo | ph in u1.posts implies ph not in u1.sees
}

pred inv3c {
	all p : User | p.sees - Ad in p.follows.posts
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 

