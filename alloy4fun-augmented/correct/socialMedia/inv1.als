module alloy4fun_augmented_socialMedia_inv1
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

pred inv1_oracle[] {
all p : Photo | one posts.p
}

pred inv1_correct_0[] {
all x: Photo | one posts.x
}

pred inv1_correct_1[] {
all x : Photo | some y : User | y->x in posts
all x : Photo | all y,z : User | y->x in posts and z->x in posts implies y = z
}

pred inv1_correct_2[] {
all p:Photo| one u:User| u->p in posts
}

pred inv1_correct_3[] {
all p: Photo| one u:User| p in u.posts
}

pred inv1_correct_4[] {
all u1,u2:User | all p:Photo | (u1->p in posts and u2->p in posts) implies u1=u2
all x:Photo | some y:User | y->x in posts
}

pred inv1_correct_5[] {
all p: Photo | one x : User | x -> p in posts
}

pred inv1_correct_6[] {
posts in User one -> set Photo
}

pred inv1_correct_7[] {
all photo: Photo | photo in User.posts
all photo: Photo | all user1, user2: User | photo in user1.posts and photo in user2.posts implies user1 = user2
}

pred inv1_correct_8[] {
all i : Photo | one u : User | u in posts.i
}

pred inv1_correct_9[] {
all p: Photo | one p.~posts
}

pred inv1_correct_10[] {
all x : Photo | one y : User | y->x in posts
}

pred inv1_correct_11[] {
all i: Photo | one u: User | u in i.~posts
}

pred inv1_correct_12[] {
all x : Photo | some y : User | y -> x in posts




all x : Photo | some posts.x

all x : Photo | one posts.x
}

pred inv1_correct_13[] {
all y : univ | y in Photo implies some x : User | x->y in posts
all p : Photo | all x, y : User | x->p in posts and y->p in posts implies x = y
}

pred inv1_correct_14[] {
all x,y : User, p : Photo | p in x.posts and p in y.posts implies x = y
all p : Photo | some x : User | p in x.posts
}

pred inv1_correct_15[] {
all a : Photo | one b : User | a in b.posts
}

pred inv1_correct_16[] {
User.posts = Photo

posts.~posts in iden
}

pred inv1_correct_17[] {
all img:Photo | one posts.img
}

pred inv1_correct_18[] {
all p : Photo | p in User.posts
all p : Photo | all user1,user2 : User | (p in user1.posts and p in user2.posts) implies user1=user2
}

pred inv1_correct_19[] {
all p: Photo |  #posts.p=1
}

pred inv1_correct_20[] {
~posts in (Photo -> one User)
}

pred inv1_correct_21[] {
posts in User lone -> Photo
posts in User some -> Photo
}

pred inv1_correct_22[] {
all i: Photo | one u: User | i in u.posts
}

pred inv1_correct_23[] {
all p : Photo | one u : User | u in posts.p
}

pred inv1_correct_24[] {
all p: Photo | one u: User | u -> p in posts
all p: Photo | one posts.p
}

pred inv1_correct_25[] {
all x: Photo | one y: User | x in y.posts
}

pred inv1_correct_26[] {
all x : Photo | some posts.x
all x : Photo | one posts.x
}

pred inv1_correct_27[] {

}

pred inv1_correct_28[] {
all p : Photo | one u:User | u->p in posts
all p: Photo | all u,v: User |u->p in posts and v->p in posts implies u=v
}

pred inv1_correct_29[] {
all u,y : User | all p : Photo | (p in u.posts and p in y.posts) implies u = y
all p : Photo | p in User.posts
}

pred inv1_correct_30[] {
all x : Photo | #(posts.x) = 1
}

pred inv1_correct_31[] {
all u1,u2:User | (some p:Photo | u1->p in posts and u2->p in posts) implies u1 = u2
all p:Photo | some u:User | u->p in posts
}

pred inv1_correct_32[] {
all i : Photo | one posts.i
}

pred inv1_correct_33[] {
all img:Photo | one u:User | u->img in posts
}

pred inv1_correct_34[] {
all u: Photo | one posts.u
}

pred inv1_correct_35[] {
posts in User lone -> set Photo
all p:Photo | some u:User | u->p in posts
}

pred inv1_correct_36[] {
all x: Photo | (one u: User | x in u.posts)
}

pred inv1_correct_37[] {
all y : Photo | one posts.y
}

pred inv1_correct_38[] {
(all x : univ | x in Photo implies some y: univ | y->x in posts) and (all x, y, z: univ| x->y in posts and z->y in posts implies x=z)
}

pred inv1_correct_39[] {
posts.~posts in iden and Photo in User.posts
}

pred inv1_correct_40[] {
all ph : Photo | one u : User | ph in u.posts
}

pred inv1_correct_41[] {
all p:Photo, u1, u2:User | u1 -> p in posts and u2 -> p in posts implies u1 = u2
all p:Photo | some u:User | u -> p in posts
}

pred inv1_correct_42[] {
all y:Photo | one u:User| y in u.posts
}

pred inv1_correct_43[] {
all im : Photo | one u : User| im in u.posts
}

pred inv1_correct_44[] {
all img : Photo | one u : User | u in img.~(posts)
}

pred inv1_correct_45[] {
all p:Photo | one x:User | p in x.posts
}

pred inv1_correct_46[] {
all x: Photo | #(x.~posts) = 1
}

pred inv1_correct_47[] {
posts in User lone -> Photo
posts in User some -> Photo

posts in User one -> Photo
}

pred inv1_correct_48[] {
all p: Photo | p in User.posts


all p: Photo | lone posts.p
}

pred inv1_correct_49[] {
posts in User some -> Photo
all u1,u2:User | (some p:Photo | u1->p in posts and u2->p in posts) implies u1 = u2
}

pred inv1_correct_50[] {
Photo in User.posts
all p : Photo | one posts.p
}

pred inv1_correct_51[] {
all image : univ | (image in Photo) implies (one user : univ | user->image in posts)
}

pred inv1_correct_52[] {
all p: Photo | some u : User | u->p in posts
all x: Photo, y,z: User | y->x in posts and z->x in posts implies y=z
}

pred inv1_correct_53[] {
all f : Photo | f in User.posts
all f : Photo | one u : User | f in u.posts
}

pred inv1_correct_54[] {
posts in User one -> set Photo

all x : Photo | one y : User | y->x in posts
}

pred inv1_correct_55[] {
all p : Photo | p in User.posts
all p : Photo | one u : User | p in u.posts
}

pred inv1_correct_56[] {
all p:Photo | some u:User | (p in u.posts and (all u2:(User-u) | p not in u2.posts))
}

pred inv1_correct_57[] {
all p : Photo | one u1 : User | u1->p in posts
}

pred inv1_correct_58[] {
all i : Photo | one u : User | u -> i in posts
}

pred inv1_correct_59[] {
all x,y : User, n : Photo | x->n in posts and y->n in posts implies x=y
all i : Photo |i in User.posts
}

pred inv1_correct_60[] {
all p : Photo | one user : User | p in user.posts
}

pred inv1_correct_61[] {
all p: Photo | lone posts.p
all p: Photo | p in User.posts
}

pred inv1_correct_62[] {
all u1, u2 : User, p : Photo | u1->p in posts and u2->p in posts implies u1 = u2
all p:Photo | some u:User | u->p in posts
}

pred inv1_correct_63[] {
all p : Photo | p in User.posts
all p : Photo | all u1,u2 : User | (p in u1.posts and p in u2.posts) implies u1=u2
}

pred inv1_correct_64[] {
User.posts = Photo
all p : Photo | lone posts.p
}

pred inv1_correct_65[] {
posts in User one -> set Photo

all x : Photo | some y : User | y->x in posts
}

pred inv1_correct_66[] {
all i : Photo | #(posts.i)=1
}

pred inv1_correct_67[] {
all p: Photo | #p.~posts = 1
}

pred inv1_correct_68[] {
all x : Photo | one posts.x
posts in User one -> set Photo
}

pred inv1_correct_69[] {
all ph:Photo, u1,u2:User | ph in u1.posts and ph in u2.posts implies u1 = u2


all ph:Photo | ph in User.posts
}

pred inv1_correct_70[] {
all p : Photo | some u : User | p in u.posts
all p : Photo | all user1, user2: User | (p in user1.posts and p in user2.posts) implies user1=user2
}

pred inv1_correct_71[] {
all photo : Photo |
one user : User | photo in user.posts
}

pred inv1_correct_72[] {
all u1, u2: User, p1 : Photo | u1->p1 in posts and u2->p1 in posts implies u1=u2
all p: Photo | some u:User | u->p in posts
}

pred inv1_correct_73[] {
all p : Photo | one y : User | y->p in posts
}

pred inv1_correct_74[] {
all p: Photo | one i: User | p in i.posts
}

pred inv1_correct_75[] {
all f : Photo | one u : User | f in u.posts
}

pred inv1_correct_76[] {
all x : Photo | some y : User | y->x in posts
all p : Photo | all y,z: User | y->p in posts and z->p in posts implies y=z
}

pred inv1_correct_77[] {
all f : Photo | f in User.posts
all f : Photo | all u1, u2 : User | f in u1.posts and f in u2.posts implies u1 = u2
}

pred inv1_correct_78[] {
all x: Photo | one x.~posts
}

pred inv1_correct_79[] {
all x : Photo | some y : User | y->x in posts

all x : Photo | one posts.x
}

pred inv1_correct_80[] {
all p: Photo | one u: User | u in posts.p
all p: Photo | one posts.p
}

pred inv1_correct_81[] {
all i : Photo | one u : User | u->i in posts
all i : Photo, u1, u2 : User | u1->i in posts and u2->i in posts implies u1 = u2
}

pred inv1_correct_82[] {
all u:User,u2:User | all p:Photo | p in u.posts and p in u2.posts implies u = u2
all p:Photo | p in User.posts
}

pred inv1_correct_83[] {
all p:Photo | some u:User | u -> p in posts
all p:Photo,u1:User,u2:User | u1 -> p in posts and u2 -> p in posts implies u1=u2
}

pred inv1_correct_84[] {
all p:Photo | some u:User | u->p in posts
all p:Photo, u1,u2:User | u1->p in posts and u2->p in posts implies u1 = u2
}

pred inv1_correct_85[] {
all x : Photo | some z : User | x in z.posts and all y, z : User | x in y.posts and x in z.posts implies y = z
}

pred inv1_correct_86[] {
all i : Photo | one u : User | u->i in posts

all u1,u2 : User, p : Photo | p in u1.posts and p in u2.posts implies u1 = u2
}

pred inv1_correct_87[] {
all x: Photo | one u: User | u->x in posts
}

pred inv1_correct_88[] {
all e : Photo | one posts.e
}

pred inv1_correct_89[] {
all y : univ | y in Photo implies some x : User | x->y in posts
all x,y,z : univ | x in User and z in User and y in Photo and x->y in posts and z->y in posts implies x=z
}

pred inv1_correct_90[] {
all x : Photo | one y : User | y in posts.x
}

pred inv1_correct_91[] {
all d : Photo | one posts.d
}

pred inv1_correct_92[] {
all y : Photo | one x : User | x->y in posts
}

pred inv1_correct_93[] {
all p:Photo | not some disj u1, u2: User | u1->p in posts and u2->p in posts
all p:Photo | some u:User | u->p in posts
}

pred inv1_correct_94[] {
all x : Photo | some y : User | y->x in posts
all x : Photo | all y,z : User | y->x in posts and z->x in posts implies y=z

all x : Photo | one posts.x
}

pred inv1_correct_95[] {
all i: Photo | one i.~posts
}

pred inv1_correct_96[] {
all i : Photo | one u : User | u -> i in posts
all x : Photo | one posts.x
}

pred inv1_correct_97[] {
all x : Photo | one posts.x
all x : Photo | one posts.x
}

pred inv1_correct_98[] {
all x : univ | x in Photo implies one u : univ | u->x in posts
}

pred inv1_correct_99[] {
all x : Photo | some u : User | u->x in posts
all p : Photo | all u,v: User | u->p in posts and v->p in posts implies u = v
}

pred inv1_correct_100[] {
all img : Photo | one (img.~posts)
}

pred inv1_correct_101[] {
all ph : Photo | #(posts.ph) = 1
}

pred inv1_correct_102[] {
all image : Photo | one u : User | image in u.posts
}

pred inv1_correct_103[] {
all y : Photo | some x : User | x->y in posts
all p : Photo | all x, y : User | x->p in posts and y->p in posts implies x = y
}

pred inv1_correct_104[] {
all p : Photo | some u : User | u->p in posts
all p : Photo | all u1,u2 : User | u1->p in posts and u2->p in posts implies u1=u2
}

