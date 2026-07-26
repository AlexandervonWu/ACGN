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
all u1, u2 : User | (u2 not in u1.follows and u2 in u1.^follows and u1 != u2) implies u2 in u1.suggested
all u1 , u2 : User | u2 in Influencer implies u2 not in u1.suggested
all u1 : User | u1 not in u1.suggested
all u1, u2 : User | u2 not in u1.^follows implies u2 not in u1.suggested
}

pred inv7c {
	all u : User | u.suggested = u.follows.follows - u.follows - u
}

check correct { inv7 <=> inv7c}
pred under { inv7 and !inv7c}
pred over { !inv7 and inv7c}
run over 
run under 

