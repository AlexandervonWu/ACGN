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
all p:Photo | all u:User | p in u.sees and p not in Ad implies p not in u.posts

all p:Photo | all u:User,u2:User | u != u2 and p in u.sees and p in u2.posts and p not in Ad implies u2 in u.follows
}

pred inv3c {
	all p : User | p.sees - Ad in p.follows.posts
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 

