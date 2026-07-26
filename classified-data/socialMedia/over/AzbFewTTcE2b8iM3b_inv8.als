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

pred inv8 {
all a:Ad | all u,u2:User | a in u2.posts and (u2 in u.follows or  u2 in u.suggested) implies a in u.sees
all a:Ad | all u:User | a in u.sees implies some u2:User | a in u2.posts and (u2 in u.suggested or u2 in u.follows)

all u:User | all p:Photo | p in u.sees implies p not in u.posts
}

pred inv8c {
	all u : User, p : u.sees & Ad | p in u.(follows+suggested).posts
}

check correct { inv8 <=> inv8c}
pred under { inv8 and !inv8c}
pred over { !inv8 and inv8c}
run over 
run under 

