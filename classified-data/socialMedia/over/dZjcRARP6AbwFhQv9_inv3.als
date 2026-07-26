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
all u, f : User, p : Photo {
u -> p in sees => p not in Ad && u -> f in follows && f -> p in posts
}







all a: Ad, u1, u2 : User | u1 -> a in sees => u2 -> a in posts && u1 != u2
}

pred inv3c {
	all p : User | p.sees - Ad in p.follows.posts
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 

