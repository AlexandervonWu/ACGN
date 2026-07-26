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
all u, j : User | all p : Photo | u -> p in sees implies u -> j in follows
all u : User| all i : Influencer| all p : Photo | u -> p in sees implies u -> i in follows



all u : User | all  a : Ad | u -> a in sees implies u -> a not in posts
all i : Influencer | all  a : Ad | i -> a in sees implies i -> a not in posts
}

pred inv3c {
	all p : User | p.sees - Ad in p.follows.posts
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 

