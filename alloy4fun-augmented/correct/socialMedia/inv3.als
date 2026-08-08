module alloy4fun_augmented_socialMedia_inv3
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

pred inv3_oracle[] {
all p : User | p.sees - Ad in p.follows.posts
}

pred inv3_correct_0[] {
all x : User | all y : x.sees | (y  in Ad) or (some k : x.follows | y in k.posts)
}

pred inv3_correct_1[] {
all x:User, p:Photo | p in x.sees implies p in Ad or p in x.follows.posts
}

pred inv3_correct_2[] {
all u : User, p : Photo - Ad | p in u.sees implies p in u.follows.posts
}

pred inv3_correct_3[] {
all u:User, p:Photo | p in u.sees => p in u.follows.posts or p in Ad
}

pred inv3_correct_4[] {
all x:User, p:Photo | p in x.sees implies p in Ad or some y:User | y in x.follows and p in y.posts
}

pred inv3_correct_5[] {
all u: User | u.sees-Ad in u.follows.posts
}

pred inv3_correct_6[] {
all u1 : User, i : Photo | (i not in Ad and u1 in sees.i) implies (some u2 : User | u1 in follows.u2 and u2 in posts.i)
}

pred inv3_correct_7[] {
all u : User | all p: Photo | p in u.sees implies (p in Ad or p in u.follows.posts)
}

pred inv3_correct_8[] {
all x : User | x.sees in (x.follows.posts + Ad)
}

pred inv3_correct_9[] {
all u : User | all p : Photo | p in u.sees implies p in Ad or some u1 : User | p in u1.posts and  u1 in u.follows
}

pred inv3_correct_10[] {
all u : User | all p : Photo | (p in u.sees and p not in Ad) implies (p in u.follows.posts)
}

pred inv3_correct_11[] {
all u1 : User | all ph : Photo |
ph in u1.sees  implies ((some u2 : User | ph in u2.posts and u2 in u1.follows ) or ph  in Ad)
}

pred inv3_correct_12[] {
all u: User | all s: u.sees | (s in u.follows.posts) or s in Ad
}

pred inv3_correct_13[] {
all p : Photo-Ad | all u : User | u->p in sees implies some v : User | v->p in posts && u->v in follows
}

pred inv3_correct_14[] {
all x: User | x.sees-Ad in x.follows.posts
}

pred inv3_correct_15[] {
all u:User, p:Photo | p in u.sees implies (p not in Ad) implies p in u.follows.posts || p in Ad
}

pred inv3_correct_16[] {
all p: Photo - Ad, u1: User | some u2: User | u1->p in sees => u2->p in posts and u1->u2 in follows
}

pred inv3_correct_17[] {
all u1 : User, i : Photo | (i not in Ad and u1 in sees.i) implies (some u2 : User | u1->u2 in follows and u2->i in posts)
}

pred inv3_correct_18[] {
all u : User | all p : Photo | u -> p in sees implies ((some u2 : User | u -> u2 in follows and u2 -> p in posts) or p in Ad)
}

pred inv3_correct_19[] {
all u : User | all p : Photo | p in u.sees implies p in u.follows.posts or p in Ad
}

pred inv3_correct_20[] {
all x:Photo,y:User| x not in Ad and x in y.sees implies some z:User| x in z.posts and z in y.follows
}

pred inv3_correct_21[] {
all p:Photo-Ad, u1: User |  u1->p in sees implies (some u2:User | u2->p in posts and u1->u2 in follows)
}

pred inv3_correct_22[] {
all u:User,p:Photo | p in u.sees => p in Ad or p in u.follows.posts
}

pred inv3_correct_23[] {
all u : User, p : Photo | p in u.sees implies (p in Ad or (u in follows.posts.p))
}

pred inv3_correct_24[] {
all u: User | all p: Photo | p in Ad or p in u.follows.posts or p not in u.sees
}

pred inv3_correct_25[] {
all u: User, p: Photo | p in u.sees-Ad implies p in u.follows.posts
}

pred inv3_correct_26[] {
all u: User, p : Photo | u -> p in sees => p in Ad || some f : User | u->f in follows && f->p in posts
}

pred inv3_correct_27[] {
all x : User | all y : x.sees | y in Ad or y in x.follows.posts
}

pred inv3_correct_28[] {
all u:User,p:Photo | u -> p in sees implies ((some u2:User | u->u2 in follows and u2->p in posts) or p in Ad)
}

pred inv3_correct_29[] {
all u:User, p:Photo | u in sees.p and p not in Ad implies some v:User | v in posts.p and u in follows.v
}

pred inv3_correct_30[] {
all u1 : User | all ph : Photo |
u1->ph in sees implies ((some u2 : User | u2->ph in posts and u2 in u1.follows ) or ph  in Ad)
}

pred inv3_correct_31[] {
all u: User | u.sees in (u.follows.posts + Ad)
}

pred inv3_correct_32[] {
all u1:User| all p:Photo | u1->p in sees and p not in Ad implies(some u2:User| u1->u2 in follows and u2->p in posts)
}

pred inv3_correct_33[] {
all u:User | all p:Photo | p in u.sees implies some v:User | p in v.posts and v in u.follows or p in Ad
}

pred inv3_correct_34[] {
all u : User | u.sees-Ad in u.follows.posts-Ad
}

pred inv3_correct_35[] {
all x : User | all p : Photo | p in x.sees implies ((some y : User | p in y.posts and x->y in follows) or (p in Ad))
}

pred inv3_correct_36[] {
all u : User | all p : Photo | p in u.sees implies (p in Ad or u in follows.posts.p)
}

pred inv3_correct_37[] {
all u:User | all p: Photo - Ad | p in u.sees implies p in (u.follows).posts
}

pred inv3_correct_38[] {
all u : User, p :  u.sees | p in u.follows.posts or p in Ad
}

pred inv3_correct_39[] {
sees in (follows.posts + User->Ad)
}

pred inv3_correct_40[] {
all u : User, p : u.sees | p in Ad+u.follows.posts
}

pred inv3_correct_41[] {
all u1 : User , p : Photo | u1->p in sees implies p in Ad or some u2 : User | u1->u2 in follows and u2->p in posts
}

pred inv3_correct_42[] {
all u:User | all p:u.sees | p in u.follows.posts or p in Ad
}

pred inv3_correct_43[] {
all u1 : User | all ph : Photo |
u1->ph in sees implies ((some u2 : User | u2->ph in posts and u1-> u2 in follows ) or ph  in Ad)
}

pred inv3_correct_44[] {
all u:User,p:Photo | p in u.sees implies (some u2:User | u2 in u.follows and p in u2.posts) or p in Ad
}

pred inv3_correct_45[] {
all u: User, p: Photo | p not in Ad && p in u.sees => p in u.follows.posts
}

pred inv3_correct_46[] {
all u1 : User | all ph : Photo |
u1 -> ph in sees implies ((some u2 : User | ph in u2.posts and u1 -> u2 in follows ) or ph in Ad)
}

pred inv3_correct_47[] {
all u:User, p:Photo | u->p in sees and p not in Ad implies u->p in follows.posts
}

pred inv3_correct_48[] {
all u:User | all us:u.sees | us in u.follows.posts or us in Ad
}

pred inv3_correct_49[] {
all u:User,p:Photo-Ad | (u->p in sees) => some u2:User | u->u2 in follows and u2->p in posts
}

pred inv3_correct_50[] {
all x, z: User | all p: Photo | x in sees.p => (p in (x.follows).posts || p in Ad)
}

pred inv3_correct_51[] {
all x : User | all y : Photo - Ad | y in x.sees implies y in x.follows.posts
}

pred inv3_correct_52[] {
all u : User | u.sees in Ad+u.follows.posts
}

pred inv3_correct_53[] {
all u:User, p:Photo-Ad | p in u.sees implies p in u.follows.posts+Ad
}

pred inv3_correct_54[] {
all u : User, p : Photo | p in u.sees implies ((p in u.follows.posts) or (p in Ad))
}

pred inv3_correct_55[] {
all x: User, z:Photo | x-> z in sees implies( (some y: User| x-> y in follows and y->z in posts) or z in Ad)
}

pred inv3_correct_56[] {
all u : User | u.sees - u.follows.posts in Ad
}

pred inv3_correct_57[] {
all u : User | u.sees in (u.follows.posts-Ad)+Ad
}

pred inv3_correct_58[] {
all u1:User, p:Photo | (u1->p in sees and p not in Ad) => (some u2:User | u1->u2 in follows and u2->p in posts)
}

pred inv3_correct_59[] {
all u : User | all p : u.sees | p not in Ad => p in u.follows.posts
}

pred inv3_correct_60[] {
all p:Photo-Ad, u1:User | u1->p in sees => (some u2:User | u1->u2 in follows and u2->p in posts)
}

pred inv3_correct_61[] {
all u : User, p: Photo | p in u.sees implies (p in Ad or p in u.follows.posts)
}

pred inv3_correct_62[] {
all p : Photo, u : User | p in u.sees => (p in Ad || p in u.follows.posts)
}

pred inv3_correct_63[] {
all u:User, p:Photo | p in u.sees => (p not in Ad) => (p in u.follows.posts || p in Ad)
}

pred inv3_correct_64[] {
all x : Photo - Ad | all u : User | x in u.sees implies x in u.follows.posts
}

pred inv3_correct_65[] {
all u : User | all ph : Photo  | ph in u.sees implies
( ph not in Ad and ph in u.follows.posts) or ph in Ad
}

pred inv3_correct_66[] {
all p:Photo, u1:User | p not in Ad and u1->p in sees implies (some u2:User | u2->p in posts and u1->u2 in follows)
}

pred inv3_correct_67[] {
all u:User, p:Photo - Ad | some v:User |u in sees.p implies v in posts.p and u in follows.v
}

pred inv3_correct_68[] {
all p : Photo, u : User | p in u.sees implies ((some v : User | p in v.posts and v in u.follows) or p in Ad)
}

pred inv3_correct_69[] {
sees:>(Photo - Ad) in follows.posts:>(Photo - Ad)
}

pred inv3_correct_70[] {
all x: User | all p: Photo | x in sees.p => (p in (x.follows).posts || p in Ad)
}

pred inv3_correct_71[] {
all u : User, seenPhotos : u.sees | seenPhotos in Ad || (seenPhotos not in Ad && seenPhotos in u.follows.posts)
}

pred inv3_correct_72[] {
all p: Photo-Ad | sees.p in follows.posts.p
}

pred inv3_correct_73[] {
all u1:User | all p:Photo | u1->p in sees implies((some u2:User | u2 -> p in posts and u1 -> u2 in follows) or p in Ad)
}

pred inv3_correct_74[] {
all x: User | all y: Photo | y in x.sees implies ((some z: User | z in posts.y and z in x.follows) or y in Ad)
}

pred inv3_correct_75[] {
all x : User | all p : Photo | x -> p in sees implies p in x.follows.posts or (p in Ad)
}

pred inv3_correct_76[] {
all p:Photo,u:User| p in u.sees =>  (some z: User | z in u.follows and p in z.posts or (p in Ad))
}

pred inv3_correct_77[] {
all u : User | no u.sees - (Ad + u.follows.posts)
}

pred inv3_correct_78[] {
all u:User, p:Photo | u in sees.p and p not in Ad implies some v:User | v->p in posts and u->v in follows
}

pred inv3_correct_79[] {
all u: User | all p: Photo | p in u.sees implies (p in u.follows.posts or p in Ad)
}

pred inv3_correct_80[] {
all u:User | all p: Photo-Ad | p in u.sees implies p in u.follows.posts + Ad
}

pred inv3_correct_81[] {
all u: User | all p: u.sees | (some f: u.follows | p in f.posts) or p in Ad
}

pred inv3_correct_82[] {
all x : User | all p : x.sees | p in x.follows.posts or p in Ad
}

pred inv3_correct_83[] {
all p : Photo | (all u1 : User | u1->p in sees and p not in Ad implies (some u2:User | u2->p in posts and u1->u2 in follows))
}

pred inv3_correct_84[] {
all p : Photo - Ad, u : User | p in u.sees implies p in u.follows.posts
}

pred inv3_correct_85[] {
all x : User |all p : x.sees | p in Ad or p in x.follows.posts
}

pred inv3_correct_86[] {
all p : Photo-Ad | all u : User | u in sees.p implies some v : User | v in posts.p and u in follows.v
}

pred inv3_correct_87[] {
all u : User, p : Photo | (p in u.sees) implies (p in u.follows.posts and p not in Ad) or (p in Ad)
}

pred inv3_correct_88[] {
all u : User, p : Photo | u->p in sees => p in Ad+u.follows.posts
}

pred inv3_correct_89[] {
all x : User | x.sees in (x.follows.posts + x.follows + Ad )
}

pred inv3_correct_90[] {
all u: User | all p: Photo-Ad | u->p in sees implies (some y: User | y in u.follows and y->p in posts)
}

pred inv3_correct_91[] {
all a:User | all p:Photo | p in a.sees => p in a.follows.posts or p in Ad
}

pred inv3_correct_92[] {
all u:User, p:Photo | u->p in sees implies (some u2:User | u2->p in posts and u->u2 in follows) or p in Ad
}

pred inv3_correct_93[] {
all p : Photo - Ad | all u : User | some u2 : User | p in u.sees implies (p in u2.posts and u2 in u.follows)
}

pred inv3_correct_94[] {
all u: User, p: Photo | u in sees.p => p in Ad+u.follows.posts
}

pred inv3_correct_95[] {
all x : User, z : Photo | z not in Ad and x in sees.z implies (some y : User | y in x.follows and y in posts.z)
}

pred inv3_correct_96[] {
all p:Photo, u:User | p in u.sees => p in Ad or p in u.follows.posts
}

pred inv3_correct_97[] {
all u: User | all p: Photo-Ad | p in u.sees implies (some y: User | y in u.follows and p in y.posts)
}

pred inv3_correct_98[] {
all u: User, p : Photo | u -> p in sees =>
p in Ad || some f : User | u->f in follows && f->p in posts

all u: User, p: Photo | u -> p in sees => p in Ad+u.follows.posts
}

pred inv3_correct_99[] {
all u : User | all p: Photo - Ad | u.sees-Ad in u.follows.posts
}

pred inv3_correct_100[] {
all x: User, y: Photo | y in x.sees implies y in Ad or some z: User | z in x.follows and y in z.posts
}

pred inv3_correct_101[] {
all u : User | all p : Photo-Ad | u->p in sees implies p in u.follows.posts
}

pred inv3_correct_102[] {
all p: Photo, u: User | p in u.sees => p in u.follows.posts or p in Ad
}

pred inv3_correct_103[] {
all p : Photo - Ad, u : User | p in u.sees implies ( some u2 : User | u2 in u.follows && p in u2.posts)
}

pred inv3_correct_104[] {
all u: User | all p: Photo-Ad | u->p in sees implies (some y: User | u->y in follows and y->p in posts)
}

pred inv3_correct_105[] {
all u:User, p:u.sees| p not in Ad implies p in u.follows.posts
}

pred inv3_correct_106[] {
all x : User | all p : Photo | some y : User | p in x.sees implies ((p in y.posts and x->y in follows) or (p in Ad))
}

pred inv3_correct_107[] {
all u:User |u.sees&(Photo-Ad) in u.follows.posts
}

pred inv3_correct_108[] {
all u : User, p : Photo | u->p in sees => p in Ad || (some f : User | f->p in posts && u->f in follows)
}

pred inv3_correct_109[] {
all x : User | all y : x.sees-Ad | y in x.follows.posts
}

pred inv3_correct_110[] {
all p: Photo-Ad | all u: sees.p | u in follows.posts.p
}

pred inv3_correct_111[] {
all x : User | all y : x.sees | y not in Ad => (some u : User | u in x.follows  && y in u.posts)
}

pred inv3_correct_112[] {
all u:User | all p:Photo-Ad | u->p in sees implies (some u2:User| u2->p in posts and u->u2 in follows)
}

pred inv3_correct_113[] {
all x : User | all y : Photo | y in x.sees implies y in Ad or y in x.follows.posts
}

pred inv3_correct_114[] {
all u : User, p : Photo | p in u.sees and p not in Ad implies p in u.follows.posts
}

pred inv3_correct_115[] {
all x : User, z : Photo-Ad | x in sees.z implies (some y : User | y in x.follows and y in posts.z)
}

pred inv3_correct_116[] {
all u : User, y : Photo| y in u.sees and y not in Ad implies y in u.follows.posts
}

pred inv3_correct_117[] {
all x: User, y: Photo | y in x.sees implies y in Ad or y in x.follows.posts
}

pred inv3_correct_118[] {
all x: User, y: Photo |  x -> y in sees implies y in Ad or some z: User | x -> z in follows and z -> y in posts
}

pred inv3_correct_119[] {
all u1 : User | all p : Photo | p in u1.sees implies ((some u2 : User | u2 in posts.p and p not in Ad and u2 in u1.follows) or p in Ad)
}

pred inv3_correct_120[] {
all u : User, p : Photo| (p in u.sees) implies ((p in u.follows.posts and p not in Ad) or (p in Ad))
}

pred inv3_correct_121[] {
all u : User, x : Photo | u->x in sees and x not in Ad implies(some v: User | u->v in follows and v->x in posts)
}

pred inv3_correct_122[] {
all x: User, z:Photo-Ad | x-> z in sees implies (some y: User| x-> y in follows and y->z in posts)
}

pred inv3_correct_123[] {
all p : User | p.sees in p.follows.posts + Ad
}

pred inv3_correct_124[] {
all u:User, p:Photo - Ad | u in sees.p implies some v:User | v in posts.p and u in follows.v
}

pred inv3_correct_125[] {
all u : User , p : Photo - Ad | p in u.sees implies (some u2 : User | p in u2.posts && u2 in u.follows)
}

pred inv3_correct_126[] {
all x : User | all y : Photo |  y in x.sees implies y in x.follows.posts or y in Ad
}

pred inv3_correct_127[] {
all x:User, y: Photo-Ad|  x-> y in sees implies ( some z:User| x->z in follows and z-> y in posts)
}

pred inv3_correct_128[] {
all u: User | all p: Photo-Ad | u->p in sees implies (some y: User | y in u.follows and p in y.posts)
}

pred inv3_correct_129[] {
all u : User, p : Photo | p in u.sees and p not in Ad implies some z: User | p in z.posts and z in u.follows
}

pred inv3_correct_130[] {
all x:User, p:Photo | p in x.sees implies p in Ad or some y:User | p in x.follows.posts
}

pred inv3_correct_131[] {
all u : User| all p : Photo | p in u.sees implies ( (p in Ad) or  (p not in Ad and p in u.follows.posts))
}

pred inv3_correct_132[] {
all x : Photo-Ad | all y : User | y in sees.x implies some z : User | z in posts.x and y in follows.z
}

pred inv3_correct_133[] {
all p: Photo , u: User |some  u1 : User | p not in Ad and u->p in sees implies(u->u1 in follows and u1->p in posts)
}

pred inv3_correct_134[] {
all x: User, y: Photo | x -> y in sees implies y in Ad or some z: User | z in x.follows and y in z.posts
}

pred inv3_correct_135[] {
all u:User, p:Photo | u -> p in sees implies (some u2:User | u -> u2 in follows and u2 -> p in posts or p in Ad)
}

pred inv3_correct_136[] {
all u : User, p : Photo | u->p in sees =>
p in Ad || p in u.follows.posts
}

pred inv3_correct_137[] {
all p:Photo,u:User | u -> p in sees implies (some u2:User | u -> u2 in follows and u2 -> p in posts) or p in Ad
}

pred inv3_correct_138[] {
all u: User, p: Photo - Ad | u in p.~sees => p  in u.follows.posts
}

pred inv3_correct_139[] {
all x : User | all y : x.sees - Ad | (some u : x.follows  | y in u.posts)
}

pred inv3_correct_140[] {
all x: User | all y: Photo-Ad | (y in x.sees) implies x in follows.posts.y
}

pred inv3_correct_141[] {
all u : User | all p : u.sees | p in Ad or p in u.follows.posts
}

pred inv3_correct_142[] {
all u : User | all p : Photo | u->p in sees and p not in Ad implies u in follows.(posts.p)
}

pred inv3_correct_143[] {
all u : User | all ph : Photo - Ad | ph in u.sees implies ph in u.follows.posts
}

pred inv3_correct_144[] {
all u:User | u.sees-Ad in u.follows.posts




all u:User | u.sees<:Ad in Ad
}

pred inv3_correct_145[] {
all x : User, p : Photo-Ad | p in x.sees implies p in x.follows.posts
}

pred inv3_correct_146[] {
all u : User | all p : u.sees | p not in Ad and p in u.follows.posts or p in Ad
}

pred inv3_correct_147[] {
all x : User | all y : x.sees | y not in Ad => (some f : x.follows | y in f.posts)
}

pred inv3_correct_148[] {
all u : User, f : Photo | (f in u.sees) implies (f not in Ad and f in u.follows.posts) or (f in Ad)
}

pred inv3_correct_149[] {
all u:User, p:Photo | p in u.sees implies (p not in Ad and p in u.follows.posts) or (p in Ad)
}

pred inv3_correct_150[] {
all u:User, p:Photo-Ad| some x:User| u->p in sees implies x->p in posts and u->x in follows
}

pred inv3_correct_151[] {
all u : User | all p : u.sees - Ad | p in u.follows.posts
}

pred inv3_correct_152[] {
all u : User, p:Photo | u -> p in sees implies (some u2:User | u->u2 in follows and u2->p in posts) or p in Ad
}

pred inv3_correct_153[] {
all u1 : User | all ph : Photo |
ph in u1.sees implies (some u2:User | ph in u2.posts and u2 in u1.follows) or ph in Ad
}

pred inv3_correct_154[] {
all u : User | all x : u.sees | x not in Ad => x in u.follows.posts
}

pred inv3_correct_155[] {
all user : User, photo : Photo | photo in user.sees => photo in user.follows.posts
or photo in Ad
}

pred inv3_correct_156[] {
all u1: User, p: Photo | p in u1.sees implies (some u2: User | u2 in u1.follows and p in u2.posts and p not in Ad) or p in Ad
}

pred inv3_correct_157[] {
all x:Photo,y:User| x not in Ad and x in y.sees implies x in y.follows.posts
}

pred inv3_correct_158[] {
all u:User | all p:Photo - Ad | p in u.sees implies some v:User | p in v.posts and v in u.follows
}

pred inv3_correct_159[] {
all u: User, i: Photo | i in u.sees && i not in Ad => i in u.follows.posts
}

pred inv3_correct_160[] {
all user : User , p : Photo | p in user.sees => p in user.follows.posts

or p in Ad
}

pred inv3_correct_161[] {
all u1 : User | all ph : Photo |
u1->ph in sees implies ((some u2 : User | ph in u2.posts and u2 in u1.follows ) or ph  in Ad)
}

pred inv3_correct_162[] {
all u1: User | all p: Photo | p in u1.sees implies (some u2: User | u2 in u1.follows and p in u2.posts and p not in Ad) or p in Ad
}

pred inv3_correct_163[] {
all x : User | all y : Photo | y not in Ad and  y not in x.follows.posts implies y not in x.sees
}

pred inv3_correct_164[] {
all x:User, p:Photo-Ad| x->p in sees implies (some u:User| x->u in follows and u->p in posts)
}

pred inv3_correct_165[] {
all p : Photo - Ad | all u : User | p in u.sees implies p in u.follows.posts
}

pred inv3_correct_166[] {
all p : Photo | all u : User | p in u.sees => p in u.follows.posts or p in Ad
}

pred inv3_correct_167[] {
all u:User, p:Photo - Ad | some v:User | u.sees-Ad in u.follows.posts
}

pred inv3_correct_168[] {
all na : Photo - Ad | all u : User | na in u.sees implies na  in u.follows.posts
}

pred inv3_correct_169[] {
all x: Photo - Ad | all u:User | x in u.sees implies some p:User | (p in u.follows) and (x in p.posts)
}

pred inv3_correct_170[] {
all x : User, y : Photo | y in x.sees implies (y in Ad or y in x.follows.posts)
}

pred inv3_correct_171[] {
all u:User, p:Photo| u -> p in sees implies ((p in Ad) or (some u2:User |  u -> u2 in follows and u2 -> p in posts))
}

pred inv3_correct_172[] {
all u : User, p : Photo | p in u.sees and p not in Ad implies some z: User | p in u.follows.posts
}

