module alloy4fun_augmented_trainStationNew_inv5
succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv5_oracle[] {
all t : Track | t not in Junction iff lone succs.t
}

pred inv5_correct_0[] {
all t : Track | (#(t.~succs)>1) iff (t in Junction)
}

pred inv5_correct_1[] {
all j : Junction | #(succs.j) > 1
all t : Track | #(succs.t) > 1 implies t in Junction
}

pred inv5_correct_2[] {
all t : Track | t in Junction iff #succs.t>1
}

pred inv5_correct_3[] {
all t1 : Track | not lone (succs.t1) iff t1 in Junction
}

pred inv5_correct_4[] {
all t : Track | #(succs.t)>1 iff t in Junction
}

pred inv5_correct_5[] {
all j : Track | #succs.j > 1 iff j in Junction
}

pred inv5_correct_6[] {
all j : Track | j in Junction iff (not lone succs.j)
}

pred inv5_correct_7[] {
all t : Track | t in Junction iff some disj t1, t2 : Track | (t1 + t2) in succs.t
}

pred inv5_correct_8[] {
all t:Track | t in Junction iff some t1,t2:Track | t->t1 in ~succs and t->t2 in ~succs and t1 != t2
}

pred inv5_correct_9[] {
Junction = Track.{t1 : Track, t2 : Track | t1->t2 in succs and (not lone succs.t2)}
}

pred inv5_correct_10[] {
all t:Track | some succs.t and not one succs.t <=> t in Junction
}

pred inv5_correct_11[] {
all t : Track | t in Junction iff some p1, p2 : succs.t | p1 != p2
}

pred inv5_correct_12[] {
all t : Track | t in Junction iff some disj t1,t2 : Track | t1 in t.(~succs) and t2 in t.(~succs)
}

pred inv5_correct_13[] {
all x: Track | x in Junction <=> #(succs.x) > 1
}

pred inv5_correct_14[] {
all t : Track | t in Junction iff not lone succs.t
}

pred inv5_correct_15[] {
all j : Track | (j in Junction) iff (some p1, p2 : Track| p1 -> j in succs and p2 -> j in succs and p1!=p2)
}

pred inv5_correct_16[] {
all t: Track| #succs.t!=1 and #succs.t!=0 <=> t in Junction
}

pred inv5_correct_17[] {
all t:Track | t in Junction iff some t1,t2:t.~succs | t1 != t2


all t:Track | t in Junction iff some t1,t2:Track | t->t1 in ~succs and t->t2 in ~succs and t1 != t2
}

pred inv5_correct_18[] {
all t:Track | t in Junction iff some t1,t2:t.~succs | t1 != t2
}

pred inv5_correct_19[] {
all j:Track | j in Junction <=> #(succs.j) > 1
}

pred inv5_correct_20[] {
all t : Track | not lone succs.t iff t in Junction
}

pred inv5_correct_21[] {
all t : Track | (t in Junction) <=> (#(t . ~succs) > 1)
}

pred inv5_correct_22[] {
all t:Track | t in Junction iff some t1,t2:Track | t1!=t2 and t in t1.succs and t in t2.succs
}

pred inv5_correct_23[] {
all x : Track | #(succs.x) > 1 iff (x in Junction)
}

pred inv5_correct_24[] {
all x : Track | (x in Junction implies #(succs.x) > 1) and (#(succs.x) > 1 implies x in Junction )
}

pred inv5_correct_25[] {
all t : Track | t in Junction iff (some disj x,y : Track | x in t.(~succs) and y in t.(~succs))
}

pred inv5_correct_26[] {
all j:Track| j in Junction <=> # j . ~succs > 1
}

pred inv5_correct_27[] {
all t : Track |  some t.~succs && not one t.~succs <=> t in Junction
}

pred inv5_correct_28[] {
all e : Track | not lone succs.e iff e in Junction
}

pred inv5_correct_29[] {
all t: Track | (t in Junction implies #succs.t > 1) and (#succs.t > 1 implies t in Junction)
}

pred inv5_correct_30[] {
all j : Junction | some t1,t2 : Track | t1!=t2 and j in t1.succs and j in t2.succs
all t,t1,t2 : Track | t1!=t2 and t in t1.succs and t in t2.succs implies t in Junction
}

pred inv5_correct_31[] {
Junction = Track-{ t : Track | lone succs.t }
}

pred inv5_correct_32[] {
all t:Junction | some t1,t2:Track | t->t1 in ~succs and t->t2 in ~succs and t1 != t2
all t:Track | (some t1,t2:Track | t->t1 in ~succs and t->t2 in ~succs and t1 != t2) implies t in Junction
}

pred inv5_correct_33[] {
all j : Junction | #succs.j > 1
all t : Track | all disj p1, p2 : Track |
p1+p2 in succs.t => t in Junction
}

pred inv5_correct_34[] {
Junction = { t : Track | not lone succs.t  }
}

pred inv5_correct_35[] {
all t : Track | t in Junction iff #succs.t>=2
}

pred inv5_correct_36[] {
all t : Track | t in Junction implies #(succs.t)>1
all t : Track | #(succs.t)>1 implies t in Junction
}

pred inv5_correct_37[] {
all j : Junction | some t1,t2: Track | t1!=t2 and j in t1.succs&t2.succs
all t1,t2,t3 : Track | t2!=t3 and t1 in t3.succs&t2.succs implies t1 in Junction
}

pred inv5_correct_38[] {
all t:Track | (some t1, t2: Track | t1!=t2 and t in t1.succs and t in t2.succs) iff t in Junction
}

pred inv5_correct_39[] {
all x : Track | x in Junction implies #(succs.x)>1
all x : Track |  #(succs.x)>1 implies x in Junction
}

pred inv5_correct_40[] {
all t: Track | all disj t1, t2: Track | t in t1.succs && t in t2.succs => t in Junction
all j: Junction | # succs.j > 1
}

pred inv5_correct_41[] {
all t : Track |  t in Junction iff (some y,z : Track | t in y.succs and t in z.succs and y!=z)
}

