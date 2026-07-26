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

pred inv4 {
all p1,p2 : Photo | all ad : Ad  | all x : User | p1 = ad and p1 in x.posts and p2 in x.posts implies p2 = ad
all u1 : User | all p1 : Photo | p1 in u1.posts implies p1 not in u1.sees
all u1 : Influencer | all p1 : Photo | p1 in u1.posts implies p1 not in u1.sees
all x : Day | some p : Photo | x = p.date
}

pred inv4c {
	all u : posts.Ad | u.posts in Ad
}

check correct { inv4 <=> inv4c}
pred under { inv4 and !inv4c}
pred over { !inv4 and inv4c}
run over 
run under 

