module alloy4fun_augmented_socialMedia_inv8
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

pred inv8_oracle[] {
all u : User, p : u.sees & Ad | p in u.(follows+suggested).posts
}

pred inv8_correct_0[] {
all u:User| all p: u.sees| p in Ad implies (p in u.follows.posts or p in u.suggested.posts)
}

pred inv8_correct_1[] {
all x : User, a : Ad | x->a in sees implies some y : User | y->a in posts and (x->y in follows or x->y in suggested)
}

pred inv8_correct_2[] {
all u : User | all p : u.sees | p not in Ad or p in u.follows.posts or p in u.suggested.posts
}

pred inv8_correct_3[] {
all u:User | u.sees & Ad in (u.follows.posts + u.suggested.posts)
}

pred inv8_correct_4[] {
all u: User |all ad: Ad | u -> ad in sees implies ad in u.follows.posts or ad in u.suggested.posts
}

pred inv8_correct_5[] {
all ad : Ad | all u : User | ad in u.sees implies ad in u.follows.posts or ad in u.suggested.posts
}

pred inv8_correct_6[] {
all ad:Ad,u:User| ad in u.sees implies ad in (u.follows.posts + u.suggested.posts)
}

pred inv8_correct_7[] {
all u : User , a : Ad | a in u.sees => a in u.follows.posts + u.suggested.posts
}

pred inv8_correct_8[] {
all u: User, a: Ad | (u in a.~sees) => (a in u.follows.posts or a in u.suggested.posts)
}

pred inv8_correct_9[] {
all u1 : User | all a : Ad | a in u1.sees implies some u2 : User | a in u2.posts and (u1->u2 in follows or u1->u2 in suggested)
}

pred inv8_correct_10[] {
all user, ad : univ | user in User and ad in Ad and user->ad in sees implies some followed, suggest : univ | (followed->ad in posts and user->followed in follows) or (suggest->ad in posts and user->suggest in suggested)
}

pred inv8_correct_11[] {
all a: Ad | all u: User | a in u.sees implies some z: User | (z in u.follows or z in u.suggested) and (a in z.posts)
}

pred inv8_correct_12[] {
all u: User | all p: u.sees | p in Ad implies p in (u.follows + u.suggested).posts
}

pred inv8_correct_13[] {
all a : Ad, u : User | a in u.sees implies some i : User | a in i.posts and (i in u.follows or i in u.suggested)
}

pred inv8_correct_14[] {
all a : Ad, u : User | a in u.sees => a in u.follows.posts or a in u.suggested.posts
}

pred inv8_correct_15[] {
all u : User | all a : Ad | u->a in sees implies a in ( (u.follows + u.suggested).posts )
}

pred inv8_correct_16[] {
all u:User,a:Ad | a in u.sees => a in u.suggested.posts or a in u.follows.posts
}

pred inv8_correct_17[] {
all u : User | (Ad & u.sees) in ((u.follows + u.suggested).posts & Ad)
}

pred inv8_correct_18[] {
all u:User | u.sees&Ad in u.(follows+suggested).posts
}

pred inv8_correct_19[] {
all x: User | all p: Photo | p in Ad && p in x.sees => some u: User | (u in x.suggested || u in x.follows) && p in u.posts
}

pred inv8_correct_20[] {
all u:User, a:Ad | u->a in sees implies (some u2:User | u2->a in posts and (u->u2 in follows or u->u2 in suggested))
}

pred inv8_correct_21[] {
all u:User | all a:Ad | a in u.sees implies some p:User | a in p.posts and p in (u.follows + u.suggested)
}

pred inv8_correct_22[] {
all u:User, a: Ad | u->a in sees implies (some u1: User | u1->a in posts and (u->u1 in follows or u->u1 in suggested))
}

pred inv8_correct_23[] {
all u: User, a: Ad | a in u.sees implies (a in u.follows.posts or a in u.suggested.posts)
}

pred inv8_correct_24[] {
all u: User | all s: u.sees | s in Ad implies (s in u.follows.posts or s in u.suggested.posts)
}

pred inv8_correct_25[] {
all u : User, a: Ad | some u1: User| a in u.sees implies a in u1.posts  and (u1 in u.follows or u1 in u.suggested)
}

pred inv8_correct_26[] {
all user : User |
user.sees & Ad in user.follows.posts + user.suggested.posts
}

pred inv8_correct_27[] {
all u : User | all p : Ad | p in u.sees implies p in u.follows.posts or p in u.suggested.posts
}

pred inv8_correct_28[] {
all u : User | all a : Ad | u in sees.a implies
( some y : User | a in y.posts and
(
(y in u.follows ) or
(y in u.suggested)
)
)
}

pred inv8_correct_29[] {
all u:User | all a : u.sees & Ad | some p : User | a in p.posts and p in (u.follows + u.suggested)
}

pred inv8_correct_30[] {
all u:User,a:Ad | a in u.sees => a in u.follows.posts or a in u.suggested.posts
}

pred inv8_correct_31[] {
all u : User | all a : u.sees & Ad | some uad : u.follows + u.suggested | a in uad.posts
}

pred inv8_correct_32[] {
all u : User | all p : u.sees & Ad | p in u.follows.posts || p in u.suggested.posts
}

pred inv8_correct_33[] {
all a : Ad , u : User | a in u.sees implies a in (u.follows.posts + u.suggested.posts)
}

pred inv8_correct_34[] {
all u : User, ad : Ad | ad in u.sees implies (ad in u.follows.posts or ad in u.suggested.posts)
}

pred inv8_correct_35[] {
all u:User,a:Ad | u->a in sees implies u->a in follows.posts or u->a in suggested.posts
}

pred inv8_correct_36[] {
all ad : Ad , user : User | ad in user.sees => (ad in user.follows.posts or ad in user.suggested.posts)
}

pred inv8_correct_37[] {
all x : User | x.sees&Ad in (x.follows.posts + x.suggested.posts)
}

pred inv8_correct_38[] {
sees :> Ad in (follows+suggested).posts :> Ad
}

pred inv8_correct_39[] {
all ad : Ad, u : User | ad in u.sees implies ad in u.follows.posts or ad in u.suggested.posts
}

pred inv8_correct_40[] {
all u: User, ad : Ad |
some f, s : User |
u->ad in sees => (f->ad in posts && u->f in follows) || (s->ad in posts && u->s in suggested)
}

pred inv8_correct_41[] {
all u: User | all p : u.sees| p in Ad => p in  u.follows.posts or p in u.suggested.posts
}

pred inv8_correct_42[] {
all u : User, ad : Ad | ad in u.sees implies ad in u.follows.posts or ad in u.suggested.posts
}

pred inv8_correct_43[] {
all u : User, a : Ad | a in u.sees implies a in (u.follows + u.suggested).posts
}

pred inv8_correct_44[] {
all u: User, p: Photo | p in u.sees and p in Ad implies p in u.follows.posts or p in u.suggested.posts
}

pred inv8_correct_45[] {
all a: Ad | all u: User | u->a in sees implies some z: User | (u->z in follows or u->z in suggested) and (z->a in posts)
}

pred inv8_correct_46[] {
all u: User | all p : Ad | p in u.sees implies ( (p in u.follows.posts) or (p in u.suggested.posts))
}

pred inv8_correct_47[] {
all x : User | all a : Ad | (a in x.sees) implies a in x.follows.posts + x.suggested.posts
}

pred inv8_correct_48[] {
all x : User, y: Ad | y in x.sees implies some z: User | y in z.posts and (z in x.follows or z in x.suggested)
}

pred inv8_correct_49[] {
all x : User | all a : x.sees | a in Ad => a in x.follows.posts or a in x.suggested.posts
}

pred inv8_correct_50[] {
all u: User | all p: u.sees | p in Ad implies p in (u.follows + u.suggested).posts & Ad
}

pred inv8_correct_51[] {
all ad : Ad | all u1,u2 : User | ad in u1.sees implies (ad in u1.follows.posts or ad in u1.suggested.posts)
}

pred inv8_correct_52[] {
all u : User, ad : Ad | ad in u.sees implies ad in u.follows.posts or ad in u.suggested.posts
all u : User, ad : Ad | ad in u.sees implies ad in u.follows.posts + u.suggested.posts
}

pred inv8_correct_53[] {
all u : User | all ad : u.sees & Ad | ad in u.follows.posts or ad in u.suggested.posts
}

pred inv8_correct_54[] {
all a : Ad | all u : User | a in u.sees implies a in u.follows.posts or a in u.suggested.posts
}

pred inv8_correct_55[] {
all x : User, y : Ad | y in x.sees implies (y in x.follows.posts or y in x.suggested.posts)
}

pred inv8_correct_56[] {
all u : User | (all p : Photo | u->p in sees and p in Ad implies ( some u2:User | (u->u2 in follows or u->u2 in suggested) and u2->p in posts))
}

pred inv8_correct_57[] {
all x: User, y: Photo | y in x.sees and y in Ad implies y in x.follows.posts or y in x.suggested.posts
}

pred inv8_correct_58[] {
all x:User | all a:Ad | a in x.sees implies some p:User | a in p.posts and p in (x.follows + x.suggested)
}

pred inv8_correct_59[] {
all u: User | all a: Ad | a in u.sees implies a in u.follows.posts or a in u.suggested.posts
}

pred inv8_correct_60[] {
all u:User, a:Ad|u->a in sees => (some u2:User | u2->a in posts and u->u2 in follows + suggested)
}

pred inv8_correct_61[] {
all user : User | all ad : Ad | ad in user.sees implies (ad in user.follows.posts or ad in user.suggested.posts)
}

pred inv8_correct_62[] {
all u: User | (u.sees & Ad) in (u.follows + u.suggested).posts
}

pred inv8_correct_63[] {
all u: User | all a : u.sees | a in Ad implies ( a in u.follows.posts or a in u.suggested.posts)
}

pred inv8_correct_64[] {
all u1 : User | u1.sees&Ad in (u1.follows.posts+u1.suggested.posts)&Ad
}

pred inv8_correct_65[] {
all ad : Ad | all u1 : User | ad in u1.sees implies (ad in u1.follows.posts or ad in u1.suggested.posts)
}

pred inv8_correct_66[] {
all u : User | all a : Ad | a in u.sees implies (a in u.follows.posts or a in u.suggested.posts)
}

pred inv8_correct_67[] {
all x:Ad,y:User| x in y.sees implies x in y.follows.posts or x in y.suggested.posts
}

pred inv8_correct_68[] {
all u:User, p:u.sees|p in Ad implies p in u.follows.posts or p in u.suggested.posts
}

pred inv8_correct_69[] {
all user : User | all ad : user.sees | ad in Ad implies ((some following : user.follows | following->ad in posts) or some suggested : user.suggested | suggested->ad in posts)
}

pred inv8_correct_70[] {
all x : User, a : Ad | a in x.sees implies a in x.follows.posts or a in x.suggested.posts
}

pred inv8_correct_71[] {
all u: User , a: Ad | u.sees & Ad  in  (u.follows + u.suggested).posts
}

pred inv8_correct_72[] {
all u : User| all ad : Ad| ad in u.sees implies (ad in u.follows.posts or ad in u.suggested.posts)
}

pred inv8_correct_73[] {
all u2 : User, ad : Ad | (ad in u2.sees) implies (ad in u2.follows.posts or ad in u2.suggested.posts)
}

pred inv8_correct_74[] {
all x: User | all y: Ad | y in x.sees implies some p: User | p in (x.follows + x.suggested) and y in p.posts
}

pred inv8_correct_75[] {
all x : User, a : Ad | a in x.sees implies (some y: User | a in y.posts and (y in x.follows + x.suggested))
}

pred inv8_correct_76[] {
all x:Ad,y:User| x in y.sees implies x in (y.follows.posts + y.suggested.posts)
}

pred inv8_correct_77[] {
all u:User | no (u.sees & Ad) - ((u.follows+u.suggested).posts & Ad)
}

pred inv8_correct_78[] {
all u :User, p : Ad | p in u.sees => p in u.follows.posts or p in u.suggested.posts
}

pred inv8_correct_79[] {
all u : User, a : u.sees&Ad | a in u.(follows+suggested).posts
}

pred inv8_correct_80[] {
all u:User | all a:Ad | a in u.sees implies some p:User | p in (u.follows + u.suggested) and  a in p.posts
}

pred inv8_correct_81[] {
all u:User,p:Ad | p in u.sees implies (p in u.follows.posts or p in u.suggested.posts)
}

pred inv8_correct_82[] {
all a : Ad, u : User | a in u.sees => a in u.(suggested + follows).posts
}

pred inv8_correct_83[] {
all u1 : User, a : Ad | u1->a in sees implies some u2 : User | u2->a in posts and (u1->u2 in follows or u1->u2 in suggested)
}

pred inv8_correct_84[] {
all a:Ad,u:User | u -> a in sees implies (some p:User | p -> a in posts and (u -> p in follows or u -> p in suggested))
}

pred inv8_correct_85[] {
all u:User,a:Ad | u->a in sees implies (some u1:User | u1->a in posts and u->u1 in follows+suggested )
}

pred inv8_correct_86[] {
all u: User, p: u.sees&Ad | p in u.suggested.posts or p in u.follows.posts
}

pred inv8_correct_87[] {
all u : User | all f : Photo | f in u.sees&Ad => f in u.follows.posts+u.suggested.posts
}

pred inv8_correct_88[] {
all u1 : User, a : Ad | u1->a in sees implies some u2 : User | u2->a in posts and (u1->u2 in follows or u1->u2 in suggested)

all u : User, a : Ad | a in u.sees implies u in (follows+suggested).posts.a
}

pred inv8_correct_89[] {
all u1 : User, a : Ad | u1 in sees.a implies some u2 : User | u2 in posts.a and u1 in (follows.u2 + suggested.u2)
}

pred inv8_correct_90[] {
all u : User | all a : Ad | a in u.sees implies a in (u.follows.posts + u.suggested.posts)
}

pred inv8_correct_91[] {
all u:User | all a : u.sees & Ad | a in (u.follows.posts + u.suggested.posts & Ad)
}

pred inv8_correct_92[] {
all a : Ad | all u : User | u in sees.a implies (some y : User | (a in y.posts) and ((y in u.follows) or (y in u.suggested)))
}

pred inv8_correct_93[] {
all x : User, a : Ad | a in x.sees implies (some y: User | a in y.posts and (y in x.follows or y in x.suggested))
}

pred inv8_correct_94[] {
all u : User | all a : Ad | a in u.sees implies some followed, suggest : univ | (followed->a in posts and followed in u.follows) or (suggest->a in posts and u->suggest in suggested)
}

pred inv8_correct_95[] {
all u : User, a : Ad | a in u.sees implies (some z : User | a in z.posts and (z in u.follows or z in u.suggested))
}

pred inv8_correct_96[] {
all u : User, ad : Ad | ad in u.sees implies (some u2 : User | ad in u2.posts && (u2 in u.follows or u2 in u.suggested))
}

pred inv8_correct_97[] {
all u: User |  u.sees&Ad in (u.follows.posts + u.suggested.posts)&Ad
}

pred inv8_correct_98[] {
all u:User | all a:Ad| u->a in sees implies (some u2:User | u2->a in posts and (u->u2 in follows or u->u2 in suggested))
}

pred inv8_correct_99[] {
all u:User,a:Ad | a in u.sees implies (some u1:User | a in u1.posts and u1 in u.follows + u.suggested)
}

pred inv8_correct_100[] {
all u1: User, a: Ad | a in u1.sees implies a in (u1.follows.posts + u1.suggested.posts)
}

pred inv8_correct_101[] {
all u: User, a: Ad | a in u.sees =>
some u2: User | a in u2.posts and (u2 in u.follows or u2 in u.suggested)
}

pred inv8_correct_102[] {
all u: User |all ad: Ad | u -> ad in sees implies ad in u.follows.posts or ad in u.suggested.posts


all u:User | all a: Ad | a in u.sees implies a in u.suggested.posts or a in u.follows.posts
}

pred inv8_correct_103[] {
all x : User | all y : Ad | (y in x.sees => y in (x.follows.posts + x.suggested.posts))
}

pred inv8_correct_104[] {
sees.(Ad->Ad & iden) in (suggested + follows).posts
}

pred inv8_correct_105[] {
all a : Ad | all u : User | a in u.sees implies a in u.suggested.posts or a in u.follows.posts
}

pred inv8_correct_106[] {
all p : Ad | all u : User | p in u.sees implies (p in u.follows.posts) or (p in u.suggested.posts)
}

pred inv8_correct_107[] {
all u:User, a: u.sees&Ad | (a in u.follows.posts) or (a in u.suggested.posts)
}

pred inv8_correct_108[] {
all u1 : User, a : Ad | u1 in sees.a implies some u2 : User | u2 in posts.a and (u1 in follows.u2 or u1 in suggested.u2)
}

pred inv8_correct_109[] {
all u : User, p:u.sees | p in Ad implies (p in u.follows.posts or p in u.suggested.posts)
}

pred inv8_correct_110[] {
all a: Ad | all u: User | a in u.sees implies a in (u.follows.posts + u.suggested.posts)
}

pred inv8_correct_111[] {
all u:User | Ad & u.sees in (u.follows.posts + u.suggested.posts)
}

pred inv8_correct_112[] {
all u:User | (u.sees & Ad) in ((u.follows.posts & Ad) + (u.suggested.posts & Ad))
}

pred inv8_correct_113[] {
sees & (univ -> Ad) in (suggested + follows).posts
}

pred inv8_correct_114[] {
all u : User | all a : Ad | a in u.sees implies some followed, suggest : univ | (followed->a in posts and u->followed in follows) or (suggest->a in posts and u->suggest in suggested)
}

pred inv8_correct_115[] {
all u : User, ad : Ad | ad in u.sees implies ad in u.follows.posts + u.suggested.posts
}

pred inv8_correct_116[] {
all u:User, a:Ad|u->a in sees => (some u2:u.follows+u.suggested | u2->a in posts )
}

pred inv8_correct_117[] {
all ad: Ad | all user: User |  ad in user.sees implies (ad in user.follows.posts or ad in user.suggested.posts)
}

