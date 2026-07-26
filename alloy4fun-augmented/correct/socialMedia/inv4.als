module alloy4fun_augmented_socialMedia_inv4
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

pred inv4_oracle[] {
all u : posts.Ad | u.posts in Ad
}

pred inv4_correct_0[] {
all x:User, y:Ad | x-> y in posts implies x.posts in Ad
}

pred inv4_correct_1[] {
all u : User | all ad : Ad | ad in u.posts implies u.posts in Ad
}

pred inv4_correct_2[] {
all u : User| all p : Ad|all p2 : u.posts| p in u.posts implies p2 in Ad
}

pred inv4_correct_3[] {
all u : User, a : Ad | a in u.posts implies u.posts in Ad
}

pred inv4_correct_4[] {
all u:User, p:Photo | p in u.posts and p in Ad implies u.posts in Ad
}

pred inv4_correct_5[] {
all x : User, y : Photo | y in Ad and y in x.posts implies (x.posts in Ad)
}

pred inv4_correct_6[] {
all user : User |
(some user.posts & Ad) implies user.posts & Ad = user.posts
}

pred inv4_correct_7[] {
all u : User | all f : Photo | f in Ad&u.posts implies u.posts in Ad
}

pred inv4_correct_8[] {
all u : User | some  u.posts & Ad implies u.posts in Ad
}

pred inv4_correct_9[] {
all u: User | u.posts in Ad or u.posts in Photo - Ad
}

pred inv4_correct_10[] {
all u : User | all a : Ad | a in u.posts implies u.posts in Ad
}

pred inv4_correct_11[] {
all u: User, p: Photo | p in (Ad & u.posts) implies u.posts in Ad
}

pred inv4_correct_12[] {
all a:Ad, u:User | u->a in posts implies (all p:Photo | u->p in posts implies p in Ad)
}

pred inv4_correct_13[] {
all u:User | (some a:Ad | u->a in posts) implies (all p:Photo | u -> p in posts implies p in Ad)
}

pred inv4_correct_14[] {
all a : User, b : Photo | b in Ad and b in a.posts implies (all c : Photo | c in a.posts implies c in Ad)
}

pred inv4_correct_15[] {
all x:User,y:Ad| y in x.posts implies x.posts in Ad
}

pred inv4_correct_16[] {
all u : User , ad : Ad | ad in u.posts implies u.posts in Ad
}

pred inv4_correct_17[] {
all u : User | some (u.posts & Ad) implies (no u.posts-Ad)
}

pred inv4_correct_18[] {
all u : User | (some pt : u.posts | pt in Ad) => (all p : u.posts | p in Ad)
}

pred inv4_correct_19[] {
all u: User | u.posts in (Photo - Ad) or u.posts in Ad
}

pred inv4_correct_20[] {
all u : User | no u.posts & Ad or u.posts in Ad
}

pred inv4_correct_21[] {
all p1,p2 : Photo, u : User | p1 in u.posts and p1 in Ad => p2 in u.posts => p2 in Ad
}

pred inv4_correct_22[] {
all u: User | (some a : Ad | a in u.posts) implies  u.posts in Ad
}

pred inv4_correct_23[] {
all x, y : univ | x->y in posts and y in Ad implies (all z : univ | x->z in posts implies z in Ad)
}

pred inv4_correct_24[] {
all u:User | u.posts & Ad != none implies u.posts in Ad
}

pred inv4_correct_25[] {
all p1,p2:Photo, u:User | (p1 in Ad and u -> p1 in posts and u->p2 in posts) implies p2 in Ad
}

pred inv4_correct_26[] {
all x : User, a : Ad, p : Photo-Ad | a in x.posts implies p not in x.posts
}

pred inv4_correct_27[] {
all u : User, a: Ad, p : Photo | a in u.posts and p in u.posts implies p in Ad
}

pred inv4_correct_28[] {
all u : User, ad : Ad | u -> ad in posts implies all p : Photo | u -> p in
posts implies p in Ad
}

pred inv4_correct_29[] {
all u : User | all a : Ad | all p: Photo | a in u.posts and p in u.posts implies p in Ad
}

pred inv4_correct_30[] {
all u : User | (some a : Ad | a in u.posts) implies all p : Photo | p in u.posts implies p in Ad
}

pred inv4_correct_31[] {
all p : Ad | all f : Photo-Ad | all x : User | p in x.posts implies f not in x.posts
}

pred inv4_correct_32[] {
all u: User, a: u.posts |  a in Ad => u.posts in Ad
}

pred inv4_correct_33[] {
all u:User, p:Photo | p in Ad and u in posts.p implies (all ph:Photo | u in posts.ph implies ph in Ad)
}

pred inv4_correct_34[] {
all u: User, a: Ad | u->a in posts implies (all p: Photo | u->p in posts implies p in Ad)
}

pred inv4_correct_35[] {
all a : Ad, p : Photo - Ad, u : User | u->a in posts => u->p not in posts
}

pred inv4_correct_36[] {
all u : User | all a : Ad | a in u.posts implies all n : Photo | n in u.posts implies n in Ad
}

pred inv4_correct_37[] {
all x : User | (some y : x.posts | y in Ad) => (x.posts in Ad)
}

pred inv4_correct_38[] {
all u: User | all a: Ad | u.posts in Ad or u.posts in Photo-Ad
}

pred inv4_correct_39[] {
all u : User | (some p : Ad | (u -> p in posts)) => all p1 : Photo | (u -> p1 in posts => p1 in Ad)
}

pred inv4_correct_40[] {
all a:Ad,p:Photo,x:User | a in x.posts and p in x.posts implies p in Ad
}

pred inv4_correct_41[] {
all ad: Ad | all user: User | ad in user.posts implies user.posts in Ad
}

pred inv4_correct_42[] {
all u : User | u.posts in Ad || no u.posts & Ad
}

pred inv4_correct_43[] {
all u1: User | all p: Photo | p in u1.posts and p in Ad implies u1.posts in Ad
}

pred inv4_correct_44[] {
all u1,u2:User | all a:Ad | u1->a in posts implies (all p:Photo | u1->p in posts implies p in Ad )
}

pred inv4_correct_45[] {
all u : User | all p : u.posts | p in Ad implies u.posts in Ad
}

pred inv4_correct_46[] {
not some a : Ad, p : Photo, u : User | p not in Ad and u->a in posts and u->p in posts
}

pred inv4_correct_47[] {
all u : User, y : Photo | y in u.posts & Ad implies u.posts in Ad
}

pred inv4_correct_48[] {
all u:User,p:Ad,r:Photo | u in posts.p implies u in posts.r implies r in Ad
}

pred inv4_correct_49[] {
all u1 : User | all ad : Ad | ad in u1.posts implies u1.posts in Ad
}

pred inv4_correct_50[] {
all a : Ad | all u : User | a in u.posts implies #(u.posts-Ad) = 0
}

pred inv4_correct_51[] {
all u1 : User | all ph : Photo |
ph in u1.posts and ph in Ad implies u1.posts in Ad
}

pred inv4_correct_52[] {
all x : User | (some y : Ad | y in x.posts) implies (x.posts in Ad)
}

pred inv4_correct_53[] {
all x: User | x.posts in (Photo - Ad) or x.posts in Ad
}

pred inv4_correct_54[] {
all u : User | all p : Photo | p in u.posts and p in Ad implies u.posts in Ad
}

pred inv4_correct_55[] {
all x: User, a: Ad | x ->a in posts implies ( all p : Photo | x -> p in posts implies p in Ad)
}

pred inv4_correct_56[] {
all u1:User , a:Ad | u1->a in posts implies(all p:Photo | u1->p in posts implies p in Ad)
}

pred inv4_correct_57[] {
all p: Photo | p in Ad => (posts.p).posts in Ad
}

pred inv4_correct_58[] {
all u:User, p:Photo | p in u.posts and p in Ad implies (all p1:Photo | p1 in u.posts implies p1 in Ad)
}

pred inv4_correct_59[] {
no (posts.Ad & posts.(Photo - Ad))
}

pred inv4_correct_60[] {
all x:User | (some z:x.posts | z in Ad) implies (all y:x.posts | y in Ad)
}

pred inv4_correct_61[] {
all u: User | (some p : u.posts | p in Ad) implies u.posts in Ad
}

pred inv4_correct_62[] {
all x:User, p:Photo | p in Ad and p in x.posts implies x.posts in Ad
}

pred inv4_correct_63[] {
all user : User | all ad : Ad | user->ad in posts implies user.posts in Ad
}

pred inv4_correct_64[] {
all x : User | all a : Ad | x -> a in posts implies all z : Photo | x -> z in posts implies z in Ad
}

pred inv4_correct_65[] {
all x:User, a:Ad| x->a in posts implies x.posts in Ad
}

pred inv4_correct_66[] {
all u : User | some u.posts&Ad implies u.posts-Ad = none
}

pred inv4_correct_67[] {
all u : User | some Ad & u.posts implies no u.posts - Ad
}

pred inv4_correct_68[] {
all u: User, p : u.posts |  p in Ad => u.posts in Ad
}

pred inv4_correct_69[] {
all u:User, y:Ad | u->y in posts implies (all p:Photo | u->p in posts implies p in Ad)
}

pred inv4_correct_70[] {
all u:User, a:Ad| u->a in posts implies u.posts in Ad
}

pred inv4_correct_71[] {
all u : User, p : Photo | p in Ad and u->p in posts implies (all p2 : Photo | u->p2 in posts implies p2 in Ad )
}

pred inv4_correct_72[] {
all u : User | all p : Ad | p in u.posts implies u.posts in Ad
}

pred inv4_correct_73[] {
all u : User | u.posts in Ad or u.posts & Ad = none
}

pred inv4_correct_74[] {
all x : User | some x.posts & Ad implies x.posts in Ad
}

pred inv4_correct_75[] {
no((posts :> Ad).Ad & posts.(Photo - Ad))
}

pred inv4_correct_76[] {
all x:User, y:Photo| x-> y in posts and y in Ad implies x.posts in Ad
}

pred inv4_correct_77[] {
all u : User | all pos : u.posts | pos in Ad => (all ph : u.posts | ph in Ad)
}

pred inv4_correct_78[] {
all u: User, a: Ad, ua: a.~posts | ua in u => u.posts in Ad
}

pred inv4_correct_79[] {
all x:User, a:Ad | a in x.posts implies x.posts in Ad
}

pred inv4_correct_80[] {
all u : User, a : Ad | a in u.posts implies all p : Photo | p in u.posts implies p in Ad
}

pred inv4_correct_81[] {
all u : User, a: Ad | u in a.~posts => u.posts in Ad
}

pred inv4_correct_82[] {
all a:Ad,p:Photo,u:User | a in u.posts and p in u.posts implies p in Ad
}

pred inv4_correct_83[] {
all x : User | some x.posts & Ad implies x.posts-Ad=none
}

pred inv4_correct_84[] {
all u : User | some u.posts & Ad implies u.posts = u.posts & Ad
}

pred inv4_correct_85[] {
all u: User | (u.posts & Ad) = none or (u.posts & Ad) = u.posts
}

pred inv4_correct_86[] {
all u: User | all a: Ad | u->a in posts implies (all p: Photo| u->p in posts implies p in Ad)
}

pred inv4_correct_87[] {
all u : User | u in posts.Ad implies u.posts in Ad
}

pred inv4_correct_88[] {
all u : User | all y : Photo | y in u.posts and y in Ad implies u.posts in Ad
}

pred inv4_correct_89[] {
all user : User | all ad: Ad | ad in user.posts implies user.posts in Ad
}

pred inv4_correct_90[] {
all u : User | all f : Photo | f in Ad and f in u.posts implies u.posts in Ad
}

pred inv4_correct_91[] {
all u : User | some u.posts - Ad implies no u.posts & Ad
}

pred inv4_correct_92[] {
all p: Photo, u: User | p in u.posts and p in Ad implies u.posts - Ad = none
}

pred inv4_correct_93[] {
all u: User, p: Photo, a: Ad | p in u.posts and p not in Ad implies a not in u.posts
}

pred inv4_correct_94[] {
all u : User | all p : Photo - Ad | all a : Ad | (a in u.posts) implies (p not in u.posts)
}

pred inv4_correct_95[] {
all u1 : User , p : Photo, a : Ad | u1->a in posts and u1->p in posts implies p in Ad
}

pred inv4_correct_96[] {
all u : User | (all p : Photo | u->p in posts and p in Ad implies (all p1: Photo | u->p1 in posts implies p1 in Ad))
}

pred inv4_correct_97[] {
all x : User | all p : Photo-Ad | all a : Ad | a in x.posts implies p not in x.posts
}

pred inv4_correct_98[] {
(posts.Ad).posts in Ad
}

pred inv4_correct_99[] {
all u:User | all p:Photo | p in Ad and p in u.posts implies u.posts in Ad
}

pred inv4_correct_100[] {
all u: User | (some a: Ad | a in u.posts) => (all p: Photo - Ad | p not in u.posts)
}

pred inv4_correct_101[] {
all u: User, p: Ad | u->p in posts implies u.posts in Ad
}

pred inv4_correct_102[] {
all u : User | u.posts = u.posts - Ad or no u.posts - Ad
}

pred inv4_correct_103[] {
all u : User , ad : Ad | ad in u.posts implies (all p : Photo | p in u.posts implies p in Ad)
}

pred inv4_correct_104[] {
all u:User | all p:Photo | p in Ad and u in posts.p implies (all ph : Photo | u->ph in posts implies ph in Ad)
}

pred inv4_correct_105[] {
all p1,p2 : Photo, u : User | u->p1 in posts and p1 in Ad implies u->p2 in posts implies p2 in Ad
}

pred inv4_correct_106[] {
all u: User, a: Ad, p: Photo| u->a in posts  and p in u.posts implies p in Ad
}

pred inv4_correct_107[] {
all u : User | all p : u.posts | p in Ad implies (all p2 : u.posts | p2 in Ad)
}

pred inv4_correct_108[] {
all a : Ad | all u : User | no p : Photo - Ad | a in u.posts and p in u.posts
}

pred inv4_correct_109[] {
all x : User | (all y : x.posts | y in Ad) or (all y : x.posts | y not in Ad)
}

pred inv4_correct_110[] {
all u : User | some u.posts & Ad implies (all p : u.posts | p in Ad)
}

pred inv4_correct_111[] {
all x : User | all y : Photo | y in x.posts and y in Ad implies x.posts in Ad
}

pred inv4_correct_112[] {
all u : User | (some p : Photo | p in u.posts and p in Ad) implies u.posts in Ad
}

pred inv4_correct_113[] {
all p: Photo, u: User | p in Ad and p in u.posts implies u.posts in Ad
}

pred inv4_correct_114[] {
all u:User,p:Photo | p in Ad and u in posts.p implies all r:Photo | u in posts.r implies r in Ad
}

pred inv4_correct_115[] {
all ad : Ad | all p: Photo - Ad |all u : User | ad in u.posts implies p not in u.posts
}

pred inv4_correct_116[] {
all u : User, y : Photo | y in u.posts and y in Ad implies u.posts in Ad
}

pred inv4_correct_117[] {
all u : User | (some ph : u.posts | ph in Ad) => (all p : u.posts | p in Ad)
}

pred inv4_correct_118[] {
not some a:Ad, p: Photo-Ad, u:User | u->a in posts and u->p in posts
}

pred inv4_correct_119[] {
all u : User, p : Photo | p in u.posts and p in Ad implies (all p : u.posts | p in Ad)
}

pred inv4_correct_120[] {
all u : User , a : Ad | u in posts.a implies u.posts in Ad
}

pred inv4_correct_121[] {
all p : Photo - Ad | all u : User | all a : Ad | a in u.posts implies p not in u.posts
}

pred inv4_correct_122[] {
all u:User | u.posts&Ad != none implies u.posts-Ad = none
}

pred inv4_correct_123[] {
all user: User | all ad: Ad | ad in user.posts implies user.^(posts) in Ad
}

pred inv4_correct_124[] {
all x,y : univ | x in User and y in Ad and x->y in posts implies all z : Photo | x->z in posts implies z in Ad
}

pred inv4_correct_125[] {
all u : User, ad : Ad | u in posts.ad implies all p : Photo | u in
posts.p implies p in Ad
}

pred inv4_correct_126[] {
all u: User | all p: Photo | p in u.posts and p in Ad implies all p1: Photo | p1 in u.posts implies p1 in Ad
}

pred inv4_correct_127[] {
all u : User , p : Ad | p in u.posts implies u.posts in Ad
}

pred inv4_correct_128[] {
all u : User | all p : Photo | (p in u.posts and p in Ad) implies (all p2: Photo | p2 in u.posts implies p2 in Ad)
}

pred inv4_correct_129[] {
all u:User | (some p:Ad | u->p in posts) => u.posts in Ad
}

pred inv4_correct_130[] {
all u : User | all add : Ad | add in u.posts implies u.posts in Ad
}

pred inv4_correct_131[] {
all u:User | #(u.posts & Ad) > 0 => #(u.posts & Ad) = #(u.posts)
}

pred inv4_correct_132[] {
all u : User, p : Photo | p in u.posts && p in Ad implies (all post : Photo | post in u.posts implies post in Ad)
}

pred inv4_correct_133[] {
all u : User | all p1 : Ad |all p2 : Photo| (u->p1 in posts and u->p2 in posts )implies p2 in Ad
}

pred inv4_correct_134[] {
all x : User | (some y : Photo | y in x.posts & Ad) implies (x.posts in Ad)
}

pred inv4_correct_135[] {
all p: Ad | (posts.p).posts in Ad
}

pred inv4_correct_136[] {
all u:User, a:Ad, p:Photo | u->a in posts and u->p in posts implies p in Ad
}

pred inv4_correct_137[] {
all u:User | (some a:Ad | u->a in posts) implies (all p1:Photo | u->p1 in posts implies p1 in Ad)
}

pred inv4_correct_138[] {
all u : User | all p : Photo | all a : Ad | u->a + u->p in posts implies u.posts in Ad
}

pred inv4_correct_139[] {
all u1: User | some u1.posts & Ad implies u1.posts in Ad
}

pred inv4_correct_140[] {
all p1,p2:Photo,u:User| p1 in Ad and p1 in u.posts and p2 in u.posts implies p2 in Ad
}

pred inv4_correct_141[] {
all x : User | (some p : x.posts| p in Ad) implies (all z:x.posts| z in Ad)
}

pred inv4_correct_142[] {
all u : User, p : Photo | p in u.posts and p in Ad implies (all x : u.posts | x in Ad)
}

pred inv4_correct_143[] {
all u:User, p:Photo | u->p in posts and p in Ad => (all p2:Photo | u->p2 in posts => p2 in Ad)
}

pred inv4_correct_144[] {
all u : User | all p : Photo | all a : Ad | u->a in posts and u->p in posts implies u.posts in Ad
}

pred inv4_correct_145[] {
all u:User | (some a:Ad | u -> a in posts) implies (all p2:Photo | u -> p2 in posts implies p2 in Ad)
}

pred inv4_correct_146[] {
all u : User | some u.posts & Ad implies (u.posts & Ad = u.posts)
}

pred inv4_correct_147[] {
all u: User | no (u.posts & Ad) or (u.posts & Ad) = u.posts
}

pred inv4_correct_148[] {
all x : User | all y: Ad | all z : Photo-Ad | x in posts.y implies (x not in posts.z)
}

pred inv4_correct_149[] {
all x : User | all a : Ad | a in x.posts implies no x.posts-Ad
}

pred inv4_correct_150[] {
all x : Ad | (posts.x).posts in Ad
}

pred inv4_correct_151[] {
all u : User, ad : Ad | u in posts.ad implies all p : Photo | u -> p in
posts implies p in Ad
}

pred inv4_correct_152[] {
all x : User | ( all p : x.posts | p in Ad) or (all p : x.posts | p not in Ad)
}

pred inv4_correct_153[] {
all u : User, ad : Ad | u ->ad in posts
=> all p : Photo | u->p in posts => p in Ad

all u: User | some (u.posts&Ad) => no (u.posts-Ad)
}

pred inv4_correct_154[] {
all u:User | (some p:Ad | p in u.posts) implies (all p:Photo | p in u.posts implies p in Ad)
}

pred inv4_correct_155[] {
all u:User | (some p:Photo | u->p in posts and p in Ad) implies (all p:Photo | u->p in posts implies p in Ad)
}

pred inv4_correct_156[] {
all u : User | #(u.posts & Ad) != 0 implies u.posts in Ad
}

pred inv4_correct_157[] {
all u : User | all p1,p2 : Photo | (p1+p2) in u.posts and p1 in Ad implies p2 in Ad
}

pred inv4_correct_158[] {
all u: User | all p : Photo | ((u->p in posts and p in Ad) implies (all z: Photo | u-> z in posts implies z in Ad))
}

pred inv4_correct_159[] {
all u : User, p : Photo | p in u.posts and p in Ad implies (all p2: Photo | u.posts in Ad)
}

pred inv4_correct_160[] {
all u:User,p:Ad | all r:Photo | u in posts.p implies u in posts.r implies r in Ad
}

pred inv4_correct_161[] {
all p : Ad, u : User |  p in u.posts => u.posts in Ad
}

pred inv4_correct_162[] {
all u: User, a: Ad, p: Photo - Ad | u->a in posts => u->p not in posts
}

pred inv4_correct_163[] {
all p:Photo,p2:Photo | all u:User | p in u.posts and p in Ad and p2 in u.posts implies p2 in Ad
}

pred inv4_correct_164[] {
all u : User, p : Ad | p in u.posts => all po : u.posts | po in Ad
}

pred inv4_correct_165[] {
no((posts :> Ad).Ad & (posts :> (Photo - Ad)).Photo)
}

pred inv4_correct_166[] {
all x : User, a : Ad | a in x.posts implies all z : Photo | z in x.posts implies z in Ad
}

pred inv4_correct_167[] {
all user : User | all p: Photo | p in user.posts and p in Ad implies user.posts in Ad
}

pred inv4_correct_168[] {
all u : User | all p : u.posts | p in Ad => all po : u.posts | po in Ad
}

pred inv4_correct_169[] {
all u : User, p : Photo | u in posts.p && p in Ad => u.posts in Ad
}

pred inv4_correct_170[] {
all x : User, a : Ad | x -> a in posts implies all z : Photo | x -> z in posts implies z in Ad
}

pred inv4_correct_171[] {
all u : User | (some p : Ad | p in u.posts) => (u.posts - Ad) = none
}

pred inv4_correct_172[] {
all a : Ad | all u : posts.a | all p : u.posts | p in Ad
}

pred inv4_correct_173[] {
all u : User | all a : Ad | a in u.posts implies (all p : Photo | p in u.posts implies p in Ad)
}

pred inv4_correct_174[] {
no(posts.(Photo - Ad) <: (posts :> Ad).Ad)
}

pred inv4_correct_175[] {
all u:User | all a:Ad | a in u.posts implies not (u.posts not in Ad)
}

pred inv4_correct_176[] {
all x:User | (some y:x.posts | y in Ad) implies (all z:x.posts | z in Ad)
}

pred inv4_correct_177[] {
all u: User | all p1, p2: Photo | (p1 != p2 and p1 in Ad and (p1+p2) in u.posts) implies p2 in Ad
}

pred inv4_correct_178[] {
all x : User | all a : Ad | a in x.posts implies x.posts in Ad
}

pred inv4_correct_179[] {
all p : Photo| all u:User | (p in Ad and p in u.posts) implies ( #(u.posts - Ad)=0)
}

pred inv4_correct_180[] {
all ad : Ad | all u : posts.ad | u.posts in Ad
}

pred inv4_correct_181[] {
all u : User, p : Photo | u->p in posts and p in Ad implies u.posts in Ad
}

pred inv4_correct_182[] {
all a : Ad, u : User | a in u.posts implies u.posts in Ad
}

pred inv4_correct_183[] {
all u:User,p:Ad | u in posts.p implies all r:Photo | u in posts.r implies r in Ad
}

pred inv4_correct_184[] {
all u : User | some Ad & u.posts implies u.posts in Ad
}

pred inv4_correct_185[] {
all u : User | all p : Ad | u->p in posts implies u.posts in Ad
}

pred inv4_correct_186[] {
all u : User| all p : Photo-Ad | all a : Ad | a in u.posts implies no p & u.posts
}

pred inv4_correct_187[] {
all u : User | all n : Photo | all a : Ad | a in u.posts and n in u.posts implies n in Ad
}

pred inv4_correct_188[] {
all u:User | (some a:Ad | u->a in posts) implies u.posts in Ad
}

pred inv4_correct_189[] {
all u : User, p : u.posts | p in Ad implies all p1 : u.posts | p1 in Ad
}

pred inv4_correct_190[] {
all u : User | all p : Photo | p in Ad and u->p in posts implies all v : Photo | u->v in posts implies v in Ad
}

pred inv4_correct_191[] {
all u : User| all p : Photo-Ad | all a : Ad | a in u.posts implies not p in u.posts
}

pred inv4_correct_192[] {
all u : User, p : u.posts | p in Ad => all po : u.posts | po in Ad
}

pred inv4_correct_193[] {
all ad : Ad | all posts : posts.ad.posts | posts in Ad
}

pred inv4_correct_194[] {
all u:User | (some p:Ad | p in u.posts ) implies u.posts in Ad
}

pred inv4_correct_195[] {
all u:User | all a:Ad | a in u.posts implies all p:Photo-a | p in u.posts implies p in Ad
}

pred inv4_correct_196[] {
all p : Photo, u : User | p in u.posts and p in Ad implies (all p : u.posts | p in Ad)
}

pred inv4_correct_197[] {
all u:User, p : Photo | p in Ad and u->p in posts implies (all ph : Photo | u->ph in posts implies ph in Ad)
}

pred inv4_correct_198[] {
all ad : Ad , user : User | ad in user.posts => user.posts in Ad
}

