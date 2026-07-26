module alloy4fun_augmented_socialMedia_inv5
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

pred inv5_oracle[] {
all i : Influencer | follows.i = User - i
}

pred inv5_correct_0[] {
all u:User | u.follows&Influencer = Influencer-u
}

pred inv5_correct_1[] {
all u: User | all i: Influencer | u != i <=> u->i in follows
}

pred inv5_correct_2[] {
all x:Influencer | follows.x = User - x
}

pred inv5_correct_3[] {
all i: Influencer | all u: User | i in u.follows iff i != u
}

pred inv5_correct_4[] {
all i: Influencer | i.~follows = User - i
}

pred inv5_correct_5[] {
all i:Influencer, u:User | i!=u iff i in u.follows
}

pred inv5_correct_6[] {
all x : User, i : Influencer | x != i <=> i in x.follows
}

pred inv5_correct_7[] {
all u: User | u in Influencer implies (follows.u = User - u)
}

