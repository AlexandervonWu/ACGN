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
all user, photo : univ | (user in User) and (photo in Photo) and (user->photo in sees) implies (photo in Ad) or
(all followed : univ | (followed in User) and (followed->photo in posts) implies (user->followed in follows))

all u1,u2 : User | all ph : Photo | (ph in u1.sees) implies (ph in Ad) or (ph in u2.posts implies u2 in u1.follows)
}

pred inv3c {
	all p : User | p.sees - Ad in p.follows.posts
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 

