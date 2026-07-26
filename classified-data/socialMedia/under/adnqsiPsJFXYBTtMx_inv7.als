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
all user : User | user not in user.suggested
all user1, user2 : User + Influencer | ((user2 in user1.follows) and (user1 in user2.follows)) implies user2 not in user1.suggested
all user1, user3 : User + Influencer | user3 in user1.suggested implies (user3 in user1.follows.follows)
}

pred inv7c {
	all u : User | u.suggested = u.follows.follows - u.follows - u
}

check correct { inv7 <=> inv7c}
pred under { inv7 and !inv7c}
pred over { !inv7 and inv7c}
run over 
run under 

