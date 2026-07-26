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
all u1, u2, u3 : User | ((u1 in follows.u2) && (u2 in follows.u3)) implies (u1 in suggested.u3)
all u : User | u not in suggested.u
all u4, u5 : User | (u4 in follows.u5) implies (u4 not in suggested.u5 && u5 not in suggested.u4)
}

pred inv7c {
	all u : User | u.suggested = u.follows.follows - u.follows - u
}

check correct { inv7 <=> inv7c}
pred under { inv7 and !inv7c}
pred over { !inv7 and inv7c}
run over 
run under 

