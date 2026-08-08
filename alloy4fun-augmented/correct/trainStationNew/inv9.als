module alloy4fun_augmented_trainStationNew_inv9
succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv9_oracle[] {
all t : Track | no t.succs & Junction implies no t.signals & Semaphore
}

pred inv9_correct_0[] {
all t: Track | no Junction & t.succs => no Semaphore & t.signals
}

pred inv9_correct_1[] {
all t: Track, s:Semaphore | no t.succs & Junction => s not in t.signals
}

pred inv9_correct_2[] {
all t:Track | no t.succs & Junction => not some s:Semaphore| s in t.signals
}

pred inv9_correct_3[] {
all e : Track |  (not (some j : Junction|j in e.succs)) implies (all s : Semaphore | s not in e.signals)
}

pred inv9_correct_4[] {
all t : Track| no (t.succs & Junction) implies no (Semaphore & t.signals)
}

pred inv9_correct_5[] {
no Semaphore & (Track - succs.Junction).signals
}

pred inv9_correct_6[] {
all t:Track | no Junction&t.succs implies no t.signals&Semaphore
}

pred inv9_correct_7[] {
all t : Track | (all j : Junction | j not in t.succs) implies (all s : Semaphore | s not in t.signals)
}

pred inv9_correct_8[] {
all x : Track | no x.succs & Junction => no x.signals & Semaphore
}

pred inv9_correct_9[] {
no (Track - succs.Junction).signals :> Semaphore
}

pred inv9_correct_10[] {
all t : Track | no t.succs&Junction implies t.signals in Signal-Semaphore
}

pred inv9_correct_11[] {
all t:Track | not some (Junction & t.succs) => not some (Semaphore & t.signals)
}

pred inv9_correct_12[] {
all t : Track | all s : Semaphore | (no t.succs & Junction) implies s not in t.signals
}

pred inv9_correct_13[] {
all t:Track | (all t2:Track | t->t2 in succs implies t2 not in Junction) implies (all s:Signal | t->s in signals implies s not in Semaphore)
}

pred inv9_correct_14[] {
all t : Track | #(t.succs & Junction) = 0 implies # (t.signals & Semaphore) = 0
}

pred inv9_correct_15[] {
all x : Track | no Junction & x.succs implies no Semaphore & x.signals
}

pred inv9_correct_16[] {
all t : Track | t in signals.Semaphore implies t in succs.Junction
}

pred inv9_correct_17[] {
all t : Track | no t.succs implies no t.signals&Semaphore
all t : Track | no t.succs&Junction implies no t.signals&Semaphore
}

pred inv9_correct_18[] {
all t:Track| (not some j:Junction | t->j in succs) => (not some s:Semaphore | t->s in signals)
}

pred inv9_correct_19[] {
no ( (Track-(succs.Junction)).signals & Semaphore)
}

pred inv9_correct_20[] {
all t: Track, s:Semaphore | no t.succs & Junction => s not in t.signals
all t: Track, s:Semaphore | no t.succs & Junction => s not in t.signals
}

pred inv9_correct_21[] {
all t : Track | t not in succs.Junction implies t not in signals.Semaphore
}

pred inv9_correct_22[] {
all t : Track | no t.succs & Junction implies no t.signals :> Semaphore
}

pred inv9_correct_23[] {
all t : Track | t in Track - succs.Junction implies no t.signals & Semaphore
}

pred inv9_correct_24[] {
all t:Track | no Junction & t.succs => (not some s:Semaphore | t->s in signals)
}

pred inv9_correct_25[] {
all t:Track, s:Semaphore| no (t & succs.Junction) implies s not in t.signals
}

pred inv9_correct_26[] {
all t:Track|all s: t.signals| no (t.succs & Junction) implies s not in Semaphore
}

pred inv9_correct_27[] {
all t:Track | no t.succs & Junction  implies(all s:Semaphore | s not in t.signals)
}

pred inv9_correct_28[] {
signals.Semaphore in succs.Junction
}

pred inv9_correct_29[] {
all t : Track | signals.Semaphore in succs.Junction
}

