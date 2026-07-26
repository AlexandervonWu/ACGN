module alloy4fun_augmented_socialMedia_inv2
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

pred inv2_oracle[] {
all p : User | p not in p.follows
}

pred inv2_correct_0[] {
all u: User | u !in u.follows
}

pred inv2_correct_1[] {
all user, follower : univ | (user in User) and (follower in User) and (user->follower in follows) implies (user!=follower)
}

pred inv2_correct_2[] {
all u1,u2:User | u1->u2 in follows implies u1 != u2
}

pred inv2_correct_3[] {
all x : User | x not in follows.x
}

pred inv2_correct_4[] {
no follows&iden
}

pred inv2_correct_5[] {
all u : User | u not in follows.u
}

pred inv2_correct_6[] {
all x1,x2:User | x2 in x1.follows implies (x1 != x2)
}

pred inv2_correct_7[] {
all u : User | u -> u not in follows
}

pred inv2_correct_8[] {
all x:User |  x-> x not in follows
}

pred inv2_correct_9[] {
all x: User | x not in x.follows
}

pred inv2_correct_10[] {
no iden & follows
}

pred inv2_correct_11[] {
all x : User | all y : x.follows | x != y
}

pred inv2_correct_12[] {
all u1,u2 : User | u1 in u2.follows implies u1 != u2
}

pred inv2_correct_13[] {
all x,y: User | x->y in follows implies x!=y
}

pred inv2_correct_14[] {
all x: User | not x in follows.x
}

pred inv2_correct_15[] {
all u1 : User | u1 not in u1.follows
}

pred inv2_correct_16[] {
all u1 : User| all u2 : User | u1 = u2 implies u2 not in u1.follows
}

pred inv2_correct_17[] {
all u1, u2 : User | u2 -> u1 in follows => u2 != u1
}

pred inv2_correct_18[] {
all f1,f2 : User | f1 in f2.follows implies f1 != f2
}

pred inv2_correct_19[] {
all x : User | x not in follows.x and x not in x.follows
}

pred inv2_correct_20[] {
all u:User,u2:User | u2 in u.follows implies u!=u2
}

pred inv2_correct_21[] {
all a,b : User | a->b in follows implies a!=b
}

pred inv2_correct_22[] {
all a: User|a not in follows.a
}

pred inv2_correct_23[] {
all u: User | u not in u.follows
all u: User | no follows&iden
}

pred inv2_correct_24[] {
not some u: User | u->u in follows
}

pred inv2_correct_25[] {
all user : User |
user not in user.follows
}

pred inv2_correct_26[] {
all x:User | no x.follows&x
}

pred inv2_correct_27[] {
all x,y : User | y->x in follows implies y!=x
}

pred inv2_correct_28[] {
all u : User | not u in u.follows
}

pred inv2_correct_29[] {
all u : User | no (u.follows & u)
}

pred inv2_correct_30[] {
all u1,u2:User | u2 in u1.follows implies u1 != u2
}

pred inv2_correct_31[] {
follows in (follows - iden)
}

pred inv2_correct_32[] {
all x : User | not x->x in follows
}

pred inv2_correct_33[] {
#(iden & follows) = 0
}

pred inv2_correct_34[] {
all u: User | no (follows & iden)
}

pred inv2_correct_35[] {
no u: User | u in u.follows
}

pred inv2_correct_36[] {
all u:User | u->u not in follows
all u:User | u not in u.follows
no (follows & iden)
}

pred inv2_correct_37[] {
all u:User | u.follows & u = none
}

pred inv2_correct_38[] {
all u1: User, u2: User | u1 -> u2 in follows implies u1 != u2
}

pred inv2_correct_39[] {
all u1,u2:User | u1 = u2 implies u2 not in u1.follows
}

pred inv2_correct_40[] {
all u1 , u2 : User | u1->u2 in follows implies not u1=u2
}

pred inv2_correct_41[] {
all u1,u2:User | u1->u2 in follows and u2->u1 in follows implies u1!=u2
}

pred inv2_correct_42[] {
all x: User | not x in x.follows
}

pred inv2_correct_43[] {
all user : User | user not in follows.user
}

pred inv2_correct_44[] {
no u:User | u->u in follows
}

pred inv2_correct_45[] {
all user1: User | user1 not in user1.follows
}

pred inv2_correct_46[] {
all u1, u2 : User | u1 in u2.follows and u2 in u1.follows implies u1 != u2
}

pred inv2_correct_47[] {
all u : User | no u & u.follows
}

pred inv2_correct_48[] {
all u,x: User | u->x in follows implies u!=x
}

pred inv2_correct_49[] {
all u: User | not u->u in follows
}

pred inv2_correct_50[] {
all u1 : univ | u1 in User implies not u1->u1 in follows
}

pred inv2_correct_51[] {
all u1 : User | u1->u1 not in follows
}

pred inv2_correct_52[] {
follows = follows-iden
}

pred inv2_correct_53[] {
all u1 : User| all u2 : User | u1 -> u2 in follows implies u1 != u2
}

pred inv2_correct_54[] {
follows - iden = follows
}

pred inv2_correct_55[] {
all x : User | all y : follows.x | y != x
}

pred inv2_correct_56[] {
all x,y : univ | x->y in follows implies x != y
}

pred inv2_correct_57[] {
all x,y : User | x = y implies x not in follows.y
}

pred inv2_correct_58[] {
all u, i : User | u->i in follows implies i!=u
}

pred inv2_correct_59[] {
all y : User | y not in y.follows
}

pred inv2_correct_60[] {
all x : univ | not x->x in follows
}

pred inv2_correct_61[] {
all y : User | y not in follows.y
}

pred inv2_correct_62[] {
all user : User | user -> user not in follows
}

pred inv2_correct_63[] {
all u : User | u -> u not in follows

all u : User | u not in u.follows
}

pred inv2_correct_64[] {
all a: User | a not in a.follows
}

pred inv2_correct_65[] {
all u: User | u not in u.follows
follows - iden = follows
}

pred inv2_correct_66[] {
all u1,u2: User | u1 = u2 implies u1 not in u1.follows
}

pred inv2_correct_67[] {
all x, y : univ | x in User and y in User and x->y in follows implies x!=y
}

pred inv2_correct_68[] {
not some x: User| x in follows.x
}

pred inv2_correct_69[] {
all x,y: User | x in y.follows implies !(x=y)
}

pred inv2_correct_70[] {
all u1 : User | u1 not in follows.u1
}

pred inv2_correct_71[] {
all user : User | all f : user.follows | user not in f
}

pred inv2_correct_72[] {
all d : User | d not in d.follows
}

pred inv2_correct_73[] {
all u1, u2:User | u1=u2 => u1->u2 not in follows
}

pred inv2_correct_74[] {
all u: User | u -> u not in follows
all u: User | u not in u.follows
follows - iden = follows
}

pred inv2_correct_75[] {
all p : User | no p & p.follows
}

pred inv2_correct_76[] {
all u1, u2 : User | u1 -> u2 in follows => u2 != u1
}

pred inv2_correct_77[] {
all x : User | x not in follows.x

all x : User | x not in x.follows
}

pred inv2_correct_78[] {
all f,u : univ | u in User and u->f in follows implies f != u
}

pred inv2_correct_79[] {
all x : User | all x2 : User | x -> x2 in follows implies x != x2
}

pred inv2_correct_80[] {
all u:User | u.follows-u = u.follows
}

pred inv2_correct_81[] {
all u, a: User | a = u => u not in a.follows
}

pred inv2_correct_82[] {
all a, b : User | b in a.follows implies a != b
}

pred inv2_correct_83[] {
all u: User | u -> u not in follows
follows - iden = follows
}

pred inv2_correct_84[] {
iden - follows = iden
}

pred inv2_correct_85[] {
all x : User | x not in x.follows and x not in follows.x
}

pred inv2_correct_86[] {
all x : User | x not in x.follows and x not in follows.x
all x : Influencer | x not in x.follows and x not in follows.x
}

