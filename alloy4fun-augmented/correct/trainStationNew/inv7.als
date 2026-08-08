module alloy4fun_augmented_trainStationNew_inv7
succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv7_oracle[] {
no t : Track | t in t.^succs
}

pred inv7_correct_0[] {
all x1,x2 : Track | x1 in x2.succs implies x2 not in x1.^succs
}

pred inv7_correct_1[] {
all t : Track | t not in t.^succs
}

pred inv7_correct_2[] {
no ^succs & iden
}

pred inv7_correct_3[] {
all x : Track | x not in x.^succs
}

pred inv7_correct_4[] {
not some t:Track | t in (t.^succs)
}

pred inv7_correct_5[] {
no (iden & ^succs)
}

pred inv7_correct_6[] {
all t1,t2 : Track | t1 in t2.^succs implies t1!=t2
all t1,t2 : Track | t1 in succs.t2 implies t1!=t2
}

pred inv7_correct_7[] {
all t : Track | t not in ^succs.t
}

pred inv7_correct_8[] {
all track : univ | track in Track implies track not in track.^(succs)
}

pred inv7_correct_9[] {
all t : Track | no t.^succs&t
}

pred inv7_correct_10[] {
all t : Track | no t & t.^succs
}

pred inv7_correct_11[] {
all t:Track | t->t not in ^succs
}

pred inv7_correct_12[] {
all t1,t2 : Track | t1 in t2.^succs implies t1!=t2
}

pred inv7_correct_13[] {
no t : Track | t in t.^(~succs)
}

pred inv7_correct_14[] {
all t:Track | t not in ^succs.t and t not in t.^succs
}

