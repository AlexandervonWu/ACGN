module alloy4fun_augmented_trainStationNew_inv4
succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv4_oracle[] {
all t : Track | t in Entry iff no succs.t
}

pred inv4_correct_0[] {
all t : Track | no t.~succs <=> t in Entry
}

pred inv4_correct_1[] {
all t : Track |  #(succs.t) = 0 iff t in Entry
}

pred inv4_correct_2[] {
all t:Track | t in Entry <=> t not in Track.^(succs)
}

pred inv4_correct_3[] {
Track - Track.succs = Entry
}

pred inv4_correct_4[] {
all t: Track | t in Entry iff #succs.t = 0
}

pred inv4_correct_5[] {
Entry = Track - ~succs.Track
}

pred inv4_correct_6[] {
all t: Track | t in Entry implies t not in Track.^succs
all t: Track | t not in Track.^succs implies t in Entry
}

pred inv4_correct_7[] {
all t : Track | t in Entry iff no t.~succs
}

pred inv4_correct_8[] {
all t: Track | (t in Entry implies no succs.t) and (no succs.t implies t in Entry)
}

pred inv4_correct_9[] {
Entry = Track - (Track.succs)
}

pred inv4_correct_10[] {
all t : Track | t not in Track.succs <=> t in Entry
}

pred inv4_correct_11[] {
all e : Track | e in Entry iff (all t : Track | t not in succs.e)
}

pred inv4_correct_12[] {
all t: Track| t in Entry  iff t not in Track.succs
}

pred inv4_correct_13[] {
all t: Track | t in Entry implies t not in Track.succs
all t: Track | t not in Track.succs implies t in Entry
}

pred inv4_correct_14[] {
all t:Track | t in Entry <=> no ^(succs).t
}

pred inv4_correct_15[] {
all t : Track | t not in Track.succs implies t in Entry
all e : Entry | e not in Track.succs
}

pred inv4_correct_16[] {
all t:Track | no succs.t iff t in Entry
}

pred inv4_correct_17[] {
all t:Track | no t & Track.succs iff t in Entry
}

pred inv4_correct_18[] {
all e : Entry | e not in Track.^succs
all t : Track | t not in Track.^succs implies t in Entry
}

pred inv4_correct_19[] {
all e : Track | e not in Track.(^succs) iff e in Entry
}

pred inv4_correct_20[] {
all e : Track| e in Entry iff (not(some t : Track |e in t.succs))
}

pred inv4_correct_21[] {
no Entry & Track.succs
all t : Track | no t & Track.succs => t in Entry
}

pred inv4_correct_22[] {
all t : Entry | t not in Track.^succs
all t : Track | t not in Track.^succs implies t in Entry
}

pred inv4_correct_23[] {
all t1,t2:Track | t1 in t2.succs implies no (t1 & Entry)

all t1:Track | no (t1 & Entry) implies (some t2:Track | t1 in t2.^succs)
}

pred inv4_correct_24[] {
all t1 : Track | (succs.t1)=none iff t1 in Entry
}

pred inv4_correct_25[] {
all t : Track | t not in Track.^succs implies t in Entry
all e : Entry | e not in Track.^succs
}

pred inv4_correct_26[] {
all t : Track | no t & Track.succs => t in Entry
no Entry & Track.succs
}

pred inv4_correct_27[] {
all t : Track | (all t1 : Track | t not in t1.succs) iff t in Entry
}

pred inv4_correct_28[] {
all x : Track | x in Entry iff no succs.x
}

pred inv4_correct_29[] {
all t:Track | t in Entry iff all ts:Track | t not in ts.succs
}

pred inv4_correct_30[] {
all t : Track | (t not in Track.^(succs) <=> t in Entry)
}

pred inv4_correct_31[] {
no succs.Entry
all t : Track | no t & Track.succs => t in Entry
}

pred inv4_correct_32[] {
no succs.Entry
all t : Track | no succs.t => t in Entry
}

pred inv4_correct_33[] {
Entry = { t : Track | no succs.t}
}

pred inv4_correct_34[] {
all e : Track | e in Entry iff no succs.e
}

pred inv4_correct_35[] {
all t1,t2:Track| t1 in Entry iff t1 not in Track.^succs
}

pred inv4_correct_36[] {
all t : Track | not t in Track.succs <=> t in Entry
}

pred inv4_correct_37[] {
all e: Entry | all t: Track | e not in t.succs
all t: Track - Entry | t in Track.succs
}

pred inv4_correct_38[] {
all t : Track | (t.~(succs)=none) iff (t in Entry)
}

pred inv4_correct_39[] {
all x : Track | x in Entry implies #(succs.x)=0
all x : Track | #(succs.x)=0 implies x in Entry
}

pred inv4_correct_40[] {
all x:Track-Entry | some succs.x
no succs.Entry
}

pred inv4_correct_41[] {
all a:Entry | all a2:Track | a2->a not in succs
all a:Track | (all a2:Track | a2->a not in succs) implies a in Entry
}

pred inv4_correct_42[] {
Entry = Track - Track.^succs
}

pred inv4_correct_43[] {
Entry = Track-({ t : Track | some succs.t})
}

pred inv4_correct_44[] {
all x: Track | x in Entry <=> no ^(succs).x
}

pred inv4_correct_45[] {
all a:Track | a in Entry iff all a2:Track | a2->a not in succs
}

pred inv4_correct_46[] {
all t : Track | all e : Entry | e not in t.^succs
all t : Track | t not in Track.^succs implies t in Entry
}

pred inv4_correct_47[] {
all t: Track | #(succs.t)=0 implies t in Entry
all t: Track |  t in Entry implies #(succs.t)=0
}

pred inv4_correct_48[] {
all e:Track | e in Entry <=> no ^succs.e
}

pred inv4_correct_49[] {
all x : Track | (x in Entry implies #(succs.x) = 0) and (#(succs.x) = 0 implies x in Entry )
}

