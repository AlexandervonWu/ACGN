module alloy4fun_augmented_socialMedia_inv7
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

pred inv7_oracle[] {
all u : User | u.suggested = u.follows.follows - u.follows - u
}

pred inv7_correct_0[] {
all u1,u2 : User | u2 in u1.suggested <=> u2 not in u1.follows and u1!=u2 and u2 in u1.follows.follows
}

pred inv7_correct_1[] {
all u : User | u.suggested = (u.follows.follows - (u.follows + u))
}

pred inv7_correct_2[] {
all u1,u2 : User | u2 in u1.suggested <=> u2 not in u1.follows and u2!=u1 and u2 in u1.follows.follows
}

pred inv7_correct_3[] {
all x, z : User | x in suggested.z iff x != z and z not in x.follows and z in x.follows.follows
}

pred inv7_correct_4[] {
all x : User | all y : User | ((y not in x.follows+x) and (some z : x.follows | y in z.follows)) <=> y in x.suggested
}

pred inv7_correct_5[] {
all disj x,y,z : User | x->y in follows and y->z in follows and x->z not in follows implies x->z in suggested
all x,y : User | x->y in suggested implies x != y and x->y not in follows and some z : User | x->z in follows and z->y in follows
}

pred inv7_correct_6[] {
all u1,u2:User | u1->u2 in suggested iff (u1->u2 in follows.follows and u1->u2 not in follows and u1 != u2)
}

pred inv7_correct_7[] {
all x,y:User| y in x.suggested iff ( y in x.follows.follows and y not in x.follows and x!=y)
}

pred inv7_correct_8[] {
all x : User | all u : x.suggested | u in x.follows.follows and u not in x.follows + x
all x : User | all u : x.follows.follows - x - x.follows | u in x.suggested
}

pred inv7_correct_9[] {
all u1, u2 : User | u2 not in u1.follows and u2 in u1.follows.follows and u2!=u1 <=> u2 in u1.suggested
}

pred inv7_correct_10[] {
suggested = (follows.follows) - follows - iden
}

pred inv7_correct_11[] {
all u, s: User | s in u.suggested iff (s in u.follows.follows and u not in s and s not in u.follows)
}

pred inv7_correct_12[] {
all u1,u2 : User | u2 in u1.suggested <=> (u1 != u2 and u2 not in u1.follows and u2 in u1.follows.follows)
}

pred inv7_correct_13[] {
all u,y : User | y in u.suggested iff (u != y and (y not in u.follows) and (some z : User | (z in u.follows) and (y in z.follows)))
}

pred inv7_correct_14[] {
all x : User | (x.follows).follows - x.follows - x = x.suggested
}

pred inv7_correct_15[] {
all u,s : User | u != s => (s in u.suggested iff (s in u.follows.follows - u.follows))
all u : User | u not in u.suggested
}

pred inv7_correct_16[] {
all u1, u3 : User | (u3 in u1.suggested) iff
(u3 not in u1.follows and u1 != u3) and (some u2: User | u2 in  u1.follows and u3 in u2.follows)
}

pred inv7_correct_17[] {
all u:User, u2:User | u2 in u.suggested iff ((some u3:User | u3 in u.follows && u2 in u3.follows) && u!=u2 && u2 not in u.follows)
}

pred inv7_correct_18[] {
all x1 : User | x1.suggested = x1.follows.follows - x1.follows - x1
}

pred inv7_correct_19[] {
all u1, u2 : User | u2 in u1.suggested <=> u2 in u1.follows.follows and u2 not in (u1.follows)+u1
}

pred inv7_correct_20[] {
all u : User | u.suggested = (u.follows.follows - (u.follows + u))
all u1, u3 : User | ( some u2 : User | u1->u2 in follows and u2->u3 in follows and u1->u3 not in follows and u1 != u3 ) iff u1->u3 in suggested
}

pred inv7_correct_21[] {
all x: User | x.suggested = (x.follows).follows - x.follows - x
}

pred inv7_correct_22[] {
all u1,u2 : User | u2 in u1.suggested iff u2 in u1.follows.follows and u2 not in u1.follows and u1 != u2
}

pred inv7_correct_23[] {
all x,y : User | y in x.suggested iff( (x not in follows.y) and
( some z : User | (z in follows.y) and (z in x.follows) ) and
( x!=y ) )
}

pred inv7_correct_24[] {
all u, i : User | i in u.suggested iff some o : User | o in u.follows and i in o.follows and i not in u.follows and i!=o and u!=i and u!=o
}

pred inv7_correct_25[] {
all u : User | all s : u.suggested | some ufoll : u.follows | s not in u.follows and s in ufoll.follows and s != u
all u : User | all uf : u.follows | all uff : uf.follows - u.follows - u | uff in u.suggested
}

pred inv7_correct_26[] {
all u1,u2:User | u1 -> u2 in suggested iff (some u3:User | u1 -> u3 in follows and u3 -> u2 in follows and u1 -> u2 not in follows and u1 != u2)
}

pred inv7_correct_27[] {
all x:User | x not in x.suggested
all x, y:User | y in x.suggested iff y not in x.follows and y in x.follows.follows and x!=y
}

pred inv7_correct_28[] {
all u1, u3 : User | u1->u3 in suggested <=> (some u2:User | u1->u2 in follows and u2->u3 in follows and u1->u3 not in follows and u1!=u3)
}

pred inv7_correct_29[] {
all u1,u2 : User | u2 in u1.suggested <=> u2 not in u1.follows+u1 and u2!=u1 and u2 in u1.follows.follows
}

pred inv7_correct_30[] {
all x, y: User | x -> y in suggested iff (x != y and some z: User | x -> z in follows and z -> y in follows and not x -> y in follows)
}

pred inv7_correct_31[] {
all u1, u2 : User | u1->u2 in suggested iff (some u3 : User | u1->u3 in follows and u3->u2 in follows and u1 not in follows.u2 and u1 != u2 and u1 not in follows.u2)
}

pred inv7_correct_32[] {
all u,s : User | s in u.suggested iff (s in u.follows.follows and s not in u.follows and u!=s)
}

pred inv7_correct_33[] {
all u : User | (u.follows.follows - u.follows - u) = u.suggested
}

pred inv7_correct_34[] {
all u, y : User | y in u.suggested iff (some follows.y & u.follows) and (no y & u.follows) and u!=y
}

pred inv7_correct_35[] {
all s:User, u:User | (u in suggested.s) iff (u != s and u not in follows.s and some v:User | u in follows.v and v in follows.s)
}

pred inv7_correct_36[] {
all u : User | u not in u.suggested
all disj u : User | u.suggested = u.follows.follows - u.follows - u
}

pred inv7_correct_37[] {
all u1, u3 : User | (u1->u3 in suggested) <=>
(u1->u3 not in follows and u1 != u3) and
(some u2 : User | u1->u2 in follows and u2->u3 in follows)
}

pred inv7_correct_38[] {
all disj x, y, z: User | x->y in follows and y->z in follows and not x->z in follows implies x->z in suggested
all x, z : User| x->z in suggested implies x!=z and  x->z not in follows and some y: User | x->y in follows and y->z in follows
}

pred inv7_correct_39[] {
all u : User | u.suggested = (u.follows.follows - u - u.follows)
}

pred inv7_correct_40[] {
all x,y: User | y in x.suggested <=> ( some z: User | y in z.follows && z in x.follows && y not in x.follows) && x!=y
}

pred inv7_correct_41[] {
all u1, u3 : User | some u2 : User | (u1 -> u2 in follows and u2 -> u3 in follows and not u1 -> u3 in follows and u1 != u2 and u2 != u3) <=> u1 -> u3 in suggested and u1 != u3

all u1, u3 : User | u1 -> u3 in suggested <=> (some u2 : User | u1 -> u2 in follows and u2 -> u3 in follows and u1 -> u3 not in follows and u1 != u3)
}

pred inv7_correct_42[] {
all u1, u3 : User | ( some u2 : User | u1->u2 in follows and u2->u3 in follows and u1->u3 not in follows and u1 != u3 ) iff u1->u3 in suggested
}

pred inv7_correct_43[] {
all u1,u2 : User | u2 in u1.suggested <=> u2 not in u1.follows and u2 in u1.follows.follows and u2!=u1
}

pred inv7_correct_44[] {
all u, s : User | s in u.suggested iff s in u.follows.follows and s!= u and s not in u.follows
}

pred inv7_correct_45[] {
all u: User, y: User| y in u.suggested iff y not in u.follows && y in u.follows.follows && u not in y
}

pred inv7_correct_46[] {
all u1:User, u2:User | u1 -> u2 in suggested iff (some u3:User | u1 -> u3 in follows and u3 -> u2 in follows and u1 -> u2 not in follows and u1 != u2)
}

pred inv7_correct_47[] {
all x,y: User | y in x.suggested iff (x != y and y in x.follows.follows and y not in x.follows)
}

pred inv7_correct_48[] {
all x, z : User | x in suggested.z iff z in (x.follows.follows - x.follows - x)
}

pred inv7_correct_49[] {
all x,y: User | y in x.suggested <=> (y in x.follows.follows and y not in x.follows and y != x)
}

pred inv7_correct_50[] {
all u1, u2 : User | u2 in u1.suggested implies (u2 in u1.follows.follows and u2 not in (u1.follows)+u1)
all u1, u2 : User | (u2 in u1.follows.follows and u2 not in (u1.follows)+u1) implies u2 in u1.suggested
}

pred inv7_correct_51[] {
all u, v : User | u->v in suggested iff ( some z : User | z->v in follows and u->z in follows and u->v not in follows and v!=u)
}

pred inv7_correct_52[] {
all x,y,z : User | x.suggested = (x.follows.follows - (x.follows + x))
}

pred inv7_correct_53[] {
all u1,u2 : User | u1 in u2.suggested iff (some u3 : User | u3 in u2.follows && u1 in u3.follows) && u1 not in u2.follows && u1!=u2
}

pred inv7_correct_54[] {
all u1 : User | u1.suggested = u1.follows.follows - u1.follows - u1
}

pred inv7_correct_55[] {
all u1,u2 : User | u2 in u1.suggested <=> u2 not in u1.follows+u1 and u2 in u1.follows.follows
}

pred inv7_correct_56[] {
all u1,u2: User | (u1!=u2 and (u1 not in u2.follows) and (u1 in u2.follows.follows)) <=> (u1 in u2.suggested)
}

pred inv7_correct_57[] {
all user : User |
user.suggested = user.follows.follows - user.follows - user
}

pred inv7_correct_58[] {
all u1, u2 : User | u1 in suggested.u2 iff (some u3 : User | u1 in follows.u3 and u3 in follows.u2 and u1 not in follows.u2 and u1 != u2 and u1 not in follows.u2)
}

pred inv7_correct_59[] {
all u,i : User | u in suggested.i iff (u not in follows.i and u in follows.follows.i and u!=i)
}

pred inv7_correct_60[] {
all u,s: User | s in u.suggested iff ((s in u.follows.follows) and u!=s and not s in u.follows)
}

pred inv7_correct_61[] {
all u1,u2 : User | u1 in u2.suggested iff (some u3 : User | u1 in u3.follows && u3 in u2.follows) &&
(u1 != u2) && u1 not in u2.follows
}

pred inv7_correct_62[] {
all u: User |
u.suggested = {
ffu: u.follows.follows |
(ffu not in u.follows) and (ffu != u)
}
}

pred inv7_correct_63[] {
all u,y: User | y in u.suggested iff (u != y and ( y not in u.follows) and (some z : User | (y in z.follows) and (z in u.follows)))
}

pred inv7_correct_64[] {
all u1 : User | u1.follows.follows-u1.follows-u1 = u1.suggested
}

pred inv7_correct_65[] {
all u1,u2 : User | (u1 in u2.suggested implies (u1 in ( u2.follows.follows - u2.follows) and u1!=u2))
and
( (u1 in ( u2.follows.follows - u2.follows) and u1!=u2) implies (u1 in u2.suggested))
}

pred inv7_correct_66[] {
all u1, u2 : User | u1 in suggested.u2 iff (some u3 : User | u1 in follows.u3 - follows.u2 and u3 in follows.u2 and u1 != u2)
}

pred inv7_correct_67[] {
all u1, u2: User | u1 not in u2 and u2 in u1.follows.follows and u2 not in u1.follows iff u2 in u1.suggested
}

pred inv7_correct_68[] {
all u, y : User | y in u.suggested <=> (y != u and y not in u.follows and y in u.follows.follows)
}

pred inv7_correct_69[] {
all u1,u2:User | u2 in u1.suggested iff (some u3:User | u2 not in u1.follows and u1!=u2 and u2 in u3.follows and u3 in u1.follows)
}

pred inv7_correct_70[] {
all u,s:User| s!=u and s in u.follows.follows and s not in u.follows iff s in u.suggested
}

pred inv7_correct_71[] {
all x,z : User | (x->z in suggested) iff
(some y : User | x->y in follows and y->z in follows and x->z not in follows and x!=z)
}

pred inv7_correct_72[] {
all u1,u2:User | (u1!=u2 and u1 in u2.follows.follows and u1 not in u2.follows) <=> (u1 in u2.suggested)
}

pred inv7_correct_73[] {
all x : User |all y : User | y in x.suggested <=> ((some z : x.follows | y in z.follows) and (y not in x.follows + x))
}

pred inv7_correct_74[] {
all u : User | u.follows.follows - u - u.follows = u.suggested
}

pred inv7_correct_75[] {
all s:User | all u:User | (u in suggested.s) iff (u != s and u not in follows.s and some v:User | u in follows.v and v in follows.s)
}

pred inv7_correct_76[] {
all u, v : User | u->v in suggested iff (some z : User | u->z in follows and z->v in follows and u->v not in follows and u!=v)
}

pred inv7_correct_77[] {
all x, z : User | z in x.suggested iff x != z and z not in x.follows and z in x.follows.follows
}

pred inv7_correct_78[] {
all u : User | u.suggested = u.follows.follows - u.follows - u.iden
}

pred inv7_correct_79[] {
all u,s : User| (s in u.suggested) iff (u not in follows.s) and some (u.follows & follows.s) and u != s
}

pred inv7_correct_80[] {
all u1, u2 : User | u2 in u1.suggested implies u2 not in (u1.follows)+u1
all u1, u2 : User | u2 in u1.suggested implies u2 in u1.follows.follows
all u1,u2 : User | u2 in u1.suggested <=> u2 not in u1.follows and u2!=u1 and u2 in u1.follows.follows
}

pred inv7_correct_81[] {
all disj x, y, z : User | x->y in follows and y->z in follows and not x->z in follows implies x->z in suggested
all x, y : User | x->y in suggested implies x!=y and x->y not in follows and some z: User | x->z in follows and z->y in follows
}

pred inv7_correct_82[] {
all u1,u2 : User | (u1 in u2.suggested) <=> (u1 in ( u2.follows.follows - u2.follows) and u1!=u2)
}

pred inv7_correct_83[] {
all u1, u2 : User | u1 in suggested.u2 iff (some u3 : User | u1 in follows.u3 and u3 in follows.u2 and u1 not in follows.u2 and u1 != u2)
}

pred inv7_correct_84[] {
all u1,u2 : User | u2 in u1.suggested <=> (u1!=u2 and u2 in u1.follows.follows and u2 not in u1.follows)
}

pred inv7_correct_85[] {
all u1, u2 : User | u1->u2 in suggested iff (some u3 : User | u1->u3 in follows and u3->u2 in follows and u1->u2 not in follows and u1 != u2 and u1->u2 not in follows)
}

pred inv7_correct_86[] {
all u, s: User | s in u.suggested iff s not in u.follows and s in u.follows.follows and s != u
}

pred inv7_correct_87[] {
all u1, u2 : User | u2 in u1.suggested implies (u2 in u1.follows.follows and u2 not in (u1.follows)+u1)
all u1,u2 : User | u2 in u1.suggested <=> u2 not in u1.follows and u2!=u1 and u2 in u1.follows.follows
}

pred inv7_correct_88[] {
all disj u,uu: User, f: u.follows.follows - u | uu not in u.follows && uu in f  => uu in u.suggested
all u: User | u.suggested = (u.follows.follows - (u.follows + u))
}

pred inv7_correct_89[] {
all  u,s : User | s in u.suggested iff( s in u.follows.follows and s not in u.follows and s !=u)
}

pred inv7_correct_90[] {
all disj u1,u2 : User | u1 in u2.suggested <=> u1 in u2.follows.follows - u2.follows
no suggested & iden
}

pred inv7_correct_91[] {
all s:User | all u:User | s in u.suggested iff some u1:User | u!=s and s in u1.follows and u1 in u.follows and s not in u.follows
}

pred inv7_correct_92[] {
all u,s : User| (s in u.suggested) iff (u not in follows.s) and s in u.follows.follows and s!=u
}

pred inv7_correct_93[] {
all u,x: User | ( some y : User | u->y in follows and y->x in follows and u->x not in follows and u !=x ) iff u->x in suggested
}

pred inv7_correct_94[] {
all u1,u2 : User | (u2 in u1.suggested implies (u1 != u2 and u2 not in u1.follows and u2 in u1.follows.follows)) and ((u1 != u2 and u2 not in u1.follows and u2 in u1.follows.follows) implies u2 in u1.suggested)
}

pred inv7_correct_95[] {
all u1, u3: User | (some u2: User | u1->u2 in follows and u2->u3 in follows and not (u1->u3 in follows) and u1 != u3) <=> u1->u3 in suggested
}

pred inv7_correct_96[] {
all x,y : User | x in suggested.y iff (y in x.follows.follows and y not in x.follows and x != y )
}

pred inv7_correct_97[] {
all u1, u2:User | u1 -> u2 in suggested iff (some u3:User | u1 -> u3 in follows and u3 -> u2 in follows and u1 -> u2 not in follows and u1 != u2 and u2 != u3)
}

pred inv7_correct_98[] {
all x, y: User | x -> y in suggested iff (x!= y and not x -> y in follows and some z: User | x -> z in follows and z -> y in follows )
}

pred inv7_correct_99[] {
all u : User | u.suggested = (u.follows.follows - (u + u.follows))
}

pred inv7_correct_100[] {
all a, b : User | b in a.suggested iff a != b and (some c : User | b in c.follows and c in a.follows and b not in a.follows)
}

pred inv7_correct_101[] {
all u : User | (u.follows.follows - (u.follows + u)) = u.suggested
}

pred inv7_correct_102[] {
all x,z : User | x->z in suggested iff(x!=z and x->z not in follows and some y:User| x->y in follows and y->z in follows)
}

pred inv7_correct_103[] {
all u,u2,u3:User | u2 in u.follows and u3 in u2.follows and u3 not in u.follows and u != u2 and u != u3 implies u3 in u.suggested
all u,u2:User | u2 in u.suggested implies some u3:User | u3 in u.follows and u2 in u3.follows
all u:User | u not in u.suggested
all u,u2:User | u2 in u.follows implies u2 not in u.suggested
}

