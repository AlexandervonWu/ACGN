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

pred inv1 {
posts in User lone -> Photo
posts in User some -> Photo

posts in User one -> Photo
}

check Injetivicade {
(all p:Photo, u1,u2: User | u1 -> p in posts and u2->p in posts => u1 = u2)
iff
(posts in User lone -> Photo)
}

pred inv1c {
	all p : Photo | one posts.p
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 

