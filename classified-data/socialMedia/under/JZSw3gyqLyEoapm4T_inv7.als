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
all u,u2,u3:User | u2 in u.follows and u3 in u2.follows and u3 not in u.follows and u != u2 and u != u3 implies u3 in u.suggested
all u,u2:User | u2 in u.suggested implies some u3:User | u3 in u.follows and u2 in u3.follows
all u:User | u not in u.suggested
}

pred inv7c {
	all u : User | u.suggested = u.follows.follows - u.follows - u
}

check correct { inv7 <=> inv7c}
pred under { inv7 and !inv7c}
pred over { !inv7 and inv7c}
run over 
run under 

