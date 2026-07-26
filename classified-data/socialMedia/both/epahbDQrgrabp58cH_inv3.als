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
all p : Photo, u1,u2 : User | p in u2.~posts and u2 in u1.follows and p != Ad implies p in u1.sees

all ad : Ad, u1,u2 : User | ad in u1.sees implies ad in u2.posts and u2 not in u1.follows or u2 in u1.follows
}

pred inv3c {
	all p : User | p.sees - Ad in p.follows.posts
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 

