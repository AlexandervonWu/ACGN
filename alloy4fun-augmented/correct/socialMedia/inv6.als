module alloy4fun_augmented_socialMedia_inv6
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

pred inv6_oracle[] {
all i : Influencer, d : Day | some i.posts & date.d
}

pred inv6_correct_0[] {
all i : Influencer | all d : Day| d in i.posts.date
}

pred inv6_correct_1[] {
all i : Influencer, d : Day | some i.posts.date & d
}

pred inv6_correct_2[] {
all i : Influencer, d : Day | some p : Photo | i->p in posts and p->d in date
}

pred inv6_correct_3[] {
all x:Influencer | no Day - x.posts.date
}

pred inv6_correct_4[] {
all inf : Influencer , d : Day | d in inf.posts.date
}

pred inv6_correct_5[] {
all i : Influencer | Day in i.posts.date
}

pred inv6_correct_6[] {
all day: Day | all i: Influencer | day in i.posts.date
}

pred inv6_correct_7[] {
all i: Influencer | i.posts.date = Day
}

pred inv6_correct_8[] {
all i : Influencer | all d : Day | some p : Photo | p in i.posts and p.date = d
}

pred inv6_correct_9[] {
all d: Day, i: Influencer | some p: Photo | p -> d in date and i -> p in posts
}

pred inv6_correct_10[] {
all i : Influencer, d : Day | d in i.posts.date
}

pred inv6_correct_11[] {
all i : Influencer | Day in i.posts.date
all d: Day | all i: Influencer | d in i.posts.date
}

pred inv6_correct_12[] {
all x: User | x in Influencer => all d: Day | d in x.posts.date
}

pred inv6_correct_13[] {
all d:Day, x:Influencer|some p:Photo| p in x.posts and d in p.date
}

pred inv6_correct_14[] {
all x : Influencer | all d : Day | some p : Photo | p -> d in date and x -> p in posts
}

pred inv6_correct_15[] {
all i : Influencer | all d : Day | some p : Photo | d in p.date and i in posts.p
}

pred inv6_correct_16[] {
all i : Influencer | all d : Day | some p : Photo | i->p in posts and p->d in date
}

pred inv6_correct_17[] {
all u:Influencer, d:Day | some p:Photo | u in posts.p and p in date.d
}

pred inv6_correct_18[] {
all day : Day | all influencer : Influencer | some photo : influencer.posts | day in photo.date
}

pred inv6_correct_19[] {
all d:Day, i:Influencer | some p:Photo | i->p in posts and p->d in date
}

pred inv6_correct_20[] {
all d: Day, i: Influencer | i in d.~date.~posts
}

pred inv6_correct_21[] {
all i : Influencer, d : Day | some p : Photo | p in i.posts and d in p.date
}

pred inv6_correct_22[] {
all d: Day, x: Influencer | some y:Photo| x-> y in posts and y-> d in date
}

pred inv6_correct_23[] {
all i : Influencer, p : Day | p in  i.posts.date
}

pred inv6_correct_24[] {
all d: Day | all u: User | u in Influencer implies (d in u.posts.date)
}

pred inv6_correct_25[] {
all influencer, day : univ | influencer in Influencer and day in Day implies some photo : univ | photo->day in date and influencer->photo in posts
}

pred inv6_correct_26[] {
all u : User | u in Influencer implies (all d : Day | d in u.posts.date )
}

pred inv6_correct_27[] {
all d : Day, i : Influencer | d in i.posts.date
}

pred inv6_correct_28[] {
all i:Influencer| all z:Day | z in i.posts.date
}

pred inv6_correct_29[] {
all x:Influencer, d:Day | d in x.posts.date
}

pred inv6_correct_30[] {
all d : Day, i : Influencer | (some p : i.posts | p.date = d)
}

pred inv6_correct_31[] {
all i: Influencer | i.posts.date&Day = Day
}

pred inv6_correct_32[] {
all d : Day | (all i : Influencer | (some p : Photo | i->p in posts and p->d in date))
}

pred inv6_correct_33[] {
all d: Day| all u: Influencer | d in (u.posts).date
}

pred inv6_correct_34[] {
all d : Day, i : Influencer | some p : Photo | d in p.date and p in i.posts
}

pred inv6_correct_35[] {
all d: Day | all i: Influencer | d in i.posts.date
}

pred inv6_correct_36[] {
all i : Influencer | Day = i.posts.date
}

pred inv6_correct_37[] {
all i : Influencer | all d : Day | some i.posts.date & d
}

pred inv6_correct_38[] {
all d : Day |all x : Influencer | d in x.posts.date
}

pred inv6_correct_39[] {
all a:Influencer | all d:Day | d in a.posts.date
}

pred inv6_correct_40[] {
all i:Influencer| #(i.posts.date & Day) = #Day
}

pred inv6_correct_41[] {
all x : Influencer | all y : Day | y in x.posts.date
}

pred inv6_correct_42[] {
all d:Day, u:Influencer| some p:Photo| u->p in posts and p->d in date
}

pred inv6_correct_43[] {
all d : Day, i : Influencer | some p : i.posts | p.date in d
}

pred inv6_correct_44[] {
all i : Influencer, d : Day | some p : Photo | (i in posts.p) && (d in p.date)
}

pred inv6_correct_45[] {
all i : Influencer, d : Day |
some p : i.posts |
p.date = d
}

pred inv6_correct_46[] {
all d : Day, i : Influencer | some date.d & i.posts
}

pred inv6_correct_47[] {
all x : Day | all y : Influencer | x in y.posts.date
}

pred inv6_correct_48[] {
all d:Day | all i:Influencer | some p:Photo | p in i.posts and p in date.d
}

pred inv6_correct_49[] {
all x, y : univ | x in Influencer and y in Day implies some z : Photo | x->z in posts and z->y in date
}

pred inv6_correct_50[] {
all d : Day | all i : Influencer | some p : Photo | p in i.posts and p.date = d
}

pred inv6_correct_51[] {
all i : Influencer, d : Day | some p : Photo | d in p.date and p in i.posts
}

pred inv6_correct_52[] {
all i, d : univ | i in Influencer and d in Day implies some p : univ | i->p in posts and p->d in date
}

pred inv6_correct_53[] {
all d : Day | Influencer in (posts.date.d)
}

pred inv6_correct_54[] {
all i:Influencer, d:Day | some p:i.posts | d in p.date
}

pred inv6_correct_55[] {
all i : Influencer, d : Day | Day in i.posts.date
}

pred inv6_correct_56[] {
all d : Day, i : Influencer | some p : Photo | p in date.d && i in posts.p
}

pred inv6_correct_57[] {
all u:User | u in Influencer implies all d:Day | some p:Photo | u in posts.p and p in date.d
}

pred inv6_correct_58[] {
all i:Influencer, d:Day | some p:Photo | p->d in date and i->p in posts
}

pred inv6_correct_59[] {
all x:Influencer | x.posts.date = Day
}

pred inv6_correct_60[] {
all u:Influencer, d:Day | some p:Photo | u in posts.date.d
}

pred inv6_correct_61[] {
all d: Day, i: Influencer | some p: Photo | p in i.posts and d in p.date
}

pred inv6_correct_62[] {
all d : Day | all i : Influencer | some p : Photo | p in i.posts and p.date in d
}

pred inv6_correct_63[] {
all d : Day | all i : Influencer | some d2: i.posts.date | d2=d
}

pred inv6_correct_64[] {
all x:Day,y:Influencer| x in y.posts.date
}

pred inv6_correct_65[] {
all infl:Influencer, day:Day | some pst:Photo | infl->pst in posts and pst->day in date
}

pred inv6_correct_66[] {
all i : Influencer | all d : Day | some z : Photo | z in i.posts and z.date=d
}

pred inv6_correct_67[] {
all d: Day, i:Influencer| #(i.posts.date & Day) = #Day
}

pred inv6_correct_68[] {
all u: Influencer| all d: Day| d in u.posts.date
}

pred inv6_correct_69[] {
not some d : Day, i : Influencer | not some p : Photo | i->p in posts and p->d in date
}

pred inv6_correct_70[] {
all d : Day | all i : Influencer | some p : Photo | d in p.date and p in i.posts
}

pred inv6_correct_71[] {
all d: Day, i: Influencer | some p: i.posts | p in d.~date
}

pred inv6_correct_72[] {
all d :Day | all i : Influencer | some (i.posts.date & d)
}

pred inv6_correct_73[] {
all inf : Influencer, d : Day | (some p : Photo | (inf -> p in posts and p->d in date))
}

pred inv6_correct_74[] {
all i:Influencer | #i.posts.date = #Day
}

pred inv6_correct_75[] {
(Influencer <: posts).date = Influencer->Day
}

pred inv6_correct_76[] {
all d : Day, i : Influencer | some p : Photo | i in posts.p and p in date.d
}

pred inv6_correct_77[] {
all inf : Influencer | all day : Day | some ph : Photo | ph in inf.posts and day in  ph.date
}

pred inv6_correct_78[] {
all i : Influencer | all d : Day | some (date.d & i.posts)
}

pred inv6_correct_79[] {
all d : Day | all i : Influencer | some p: i.posts | p.date = d
}

pred inv6_correct_80[] {
all d:Day,i:Influencer | i in posts.(date.d)
}

pred inv6_correct_81[] {
Influencer <: (posts.date) = Influencer->Day
}

pred inv6_correct_82[] {
all inf : Influencer | all day : Day | some ph : Photo | ph in inf.posts and ph.date = day
}

pred inv6_correct_83[] {
all d : Day, i : Influencer | some (i.posts.date & d)
}

pred inv6_correct_84[] {
all i : Influencer, d : Day | some p : Photo | d in p.date && i in posts.p
}

pred inv6_correct_85[] {
all i : Influencer | all d : Day | some p : Photo | i in posts.p and d in p.date
}

pred inv6_correct_86[] {
all x: Day | all p: Influencer | x in p.posts.date
}

pred inv6_correct_87[] {
all i : Influencer | all d : Day | some p : Photo | d = p.date and p in i.posts
}

pred inv6_correct_88[] {
all i : Influencer | all d : Day | some z : Photo | z in i.posts and z.date in d
}

pred inv6_correct_89[] {
all d:Day | all i:Influencer |some p:Photo | p in i.posts and d in p.date
}

pred inv6_correct_90[] {
all a : Influencer, b : Day | some c : Photo | c in a.posts and b in c.date
}

pred inv6_correct_91[] {
all x:User, d:Day | x in Influencer implies d in x.posts.date
}

pred inv6_correct_92[] {
all d : Day, f : Influencer | some p : f.posts| d in p.date
}

pred inv6_correct_93[] {
Influencer -> Day in posts.date
}

pred inv6_correct_94[] {
all d:Day | all u:User | u in Influencer implies some p:Photo | p in u.posts and d in p.date
}

pred inv6_correct_95[] {
all i: Influencer | Day - i.posts.date = none
}

pred inv6_correct_96[] {
all u: User, i: Influencer, d: Day | u=i implies some p: Photo | u->p in posts and p->d in date
}

pred inv6_correct_97[] {
all i: Influencer, d: Day | some p: Photo | i->p in posts and d in p.date
}

pred inv6_correct_98[] {
all x : Influencer, d : Day | some p : Photo | x->p in posts and p->d in date
}

pred inv6_correct_99[] {
all i : Influencer | Day & i.posts.date = Day
}

pred inv6_correct_100[] {
all x : Influencer | all y : Day | some x.posts.date&y
}

pred inv6_correct_101[] {
all d : Day | all inf : Influencer | d in inf.posts.date
}

pred inv6_correct_102[] {
all i : Influencer | no (Day -i.posts.date)
}

pred inv6_correct_103[] {
all d : Day | all i : Influencer | some p : Photo | i in posts.p and d in p.date
}

pred inv6_correct_104[] {
all d:Day , i:Influencer |some p:Photo | p.date = d and p in i.posts
}

pred inv6_correct_105[] {
all i : Influencer | (i.posts&Photo).date&Day = Day
}

pred inv6_correct_106[] {
all i : Influencer | all d : Day | some p: i.posts | d in p.date
}

pred inv6_correct_107[] {
all x : Influencer | all d : Day | d in x.posts.date
}

pred inv6_correct_108[] {
all x: User, y: Day | x in Influencer implies y in x.posts.date
}

pred inv6_correct_109[] {
all u:Influencer, d:Day | u in posts.date.d
}

pred inv6_correct_110[] {
all i: Influencer | all d: Day | some p: Photo | p in i.posts and d in p.date
}

pred inv6_correct_111[] {
all i:Influencer | i.posts <: date in Photo some -> Day
}

pred inv6_correct_112[] {
all d : Day, i : Influencer | some p : date.d | p in i.posts
}

