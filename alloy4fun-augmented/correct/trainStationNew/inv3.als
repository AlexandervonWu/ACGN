module alloy4fun_augmented_trainStationNew_inv3
succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv3_oracle[] {
all t : Track | t in Exit iff no t.succs
}

pred inv3_correct_0[] {
all x: Exit |no x.succs
all t: Track | (t in Exit) <=> no t.succs
}

pred inv3_correct_1[] {
all t:Track | no t.succs iff t in Exit
}

pred inv3_correct_2[] {
all t:Track | t in Exit <=> no t.^(succs)
}

pred inv3_correct_3[] {
all x : Track - Exit | some x.succs
no Exit.succs
}

pred inv3_correct_4[] {
Exit = Track - succs.Track
}

pred inv3_correct_5[] {
all t:Track | t not in Exit <=> some t.^(succs)
}

pred inv3_correct_6[] {
no Exit.succs
all t: Track | no t.succs => t in Exit
}

pred inv3_correct_7[] {
all t : Track | no t.succs implies t in Exit
all e : Exit | no e.succs
}

pred inv3_correct_8[] {
all t : Track | #(t.succs) = 0 iff t in Exit
}

pred inv3_correct_9[] {
all t: Track | t in Exit iff t.succs in none
}

pred inv3_correct_10[] {
all x : Track | (x in Exit implies #(x.succs) = 0) and (#(x.succs) = 0 implies x in Exit )
}

pred inv3_correct_11[] {
all t : Track | (t.succs)=none iff t in Exit
}

pred inv3_correct_12[] {
all t : Track | t in Exit <=> #t.succs = 0
}

pred inv3_correct_13[] {
all a:Exit,a2:Track | a->a2 not in succs
all a:Track | (all a2:Track | a->a2 not in succs) implies a in Exit
}

pred inv3_correct_14[] {
Track - succs.Track = Exit
}

pred inv3_correct_15[] {
all t : Track | t in Exit <=> #t.succs <= 0
}

pred inv3_correct_16[] {
all t:Track | no t.succs => t in Exit
no Exit.succs
}

pred inv3_correct_17[] {
Exit = Track - Track.~succs
}

pred inv3_correct_18[] {
all t: Exit | #(t.succs)=0
all t: Track - Exit | some s : Track | s in t.succs
}

pred inv3_correct_19[] {
all t1,t2:Track | t1 not in Exit <=> some t1.^(succs)
}

pred inv3_correct_20[] {
all e : Track | e in Exit iff (all t : Track | t not in e.succs)
}

pred inv3_correct_21[] {
all a:Track | a in Exit iff all a2:Track | a->a2 not in succs
}

pred inv3_correct_22[] {
all a:Track | a in Exit iff no a.succs
}

pred inv3_correct_23[] {
all e : Track| e in Exit iff (not(some t : Track |t in e.succs))
}

pred inv3_correct_24[] {
all t1,t2:Track | t2 in t1.succs implies no (t1 & Exit)
all t1:Track | no (t1 & Exit) implies (some t2:Track | t2 in t1.succs)
}

pred inv3_correct_25[] {
all t : Track | (no t.succs implies t in Exit) and (t in Exit implies no t.succs)
}

pred inv3_correct_26[] {
all t : Track |(t in Exit implies no t.succs) and (no t.succs implies t in Exit)
}

pred inv3_correct_27[] {
all t : Track | #(t.succs) = 0 implies t in Exit
all e : Exit | #(e.succs) = 0
}

pred inv3_correct_28[] {
all e : Track | no e.succs iff e in Exit
}

pred inv3_correct_29[] {
all x : Track | x in Exit iff no x.succs
}

pred inv3_correct_30[] {
Exit = Track-({ t : Track | some t.succs})





no Exit.succs
}

pred inv3_correct_31[] {
all t: Track | #(t.succs)=0 implies t in Exit
all t: Track |  t in Exit implies #(t.succs)=0
}

pred inv3_correct_32[] {
all t : Track |t in Exit implies no t.succs
all t : Track |no t.succs implies t in Exit
}

pred inv3_correct_33[] {
all x : Track | x in Exit implies #(x.succs)=0
all x : Track | #(x.succs)=0 implies x in Exit
}

pred inv3_correct_34[] {
all t:Track | t in Exit iff all ts:Track | ts not in t.succs
}

pred inv3_correct_35[] {
all a:Track | a in Exit implies all a2:Track | a->a2 not in succs
all a:Track | (all a2:Track | a->a2 not in succs) implies a in Exit
}

pred inv3_correct_36[] {
all x:Track | x in Exit <=> no x.^succs
}

pred inv3_correct_37[] {
all t: (Track-Exit) |  some t.succs
all e: Exit, t: Track | e in t implies no t.succs
}

pred inv3_correct_38[] {
all t:Track | t not in Exit <=> some t.(succs)
}

