module alloy4fun_augmented_trainStationNew_inv10
succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv10_oracle[] {
all j : Junction, t : succs.j | some t.signals & Semaphore
}

pred inv10_correct_0[] {
all j : Junction, t : Track | j in t.succs => some Semaphore & t.signals
}

pred inv10_correct_1[] {
all t1,t2:Track | t2 in t1.succs and one (Junction & t2) implies (some s:Semaphore | s in t1.signals)
}

pred inv10_correct_2[] {
all t:Track | some (Junction & t.succs) => some (Semaphore & t.signals)
}

pred inv10_correct_3[] {
all t : Track | all j : Junction | (j in t.succs) implies (some s : Semaphore | s in t.signals)
}

pred inv10_correct_4[] {
all t : Track | some t.succs & Junction implies some t.signals & Semaphore
}

pred inv10_correct_5[] {
all j:Junction, t:Track | t in succs.j => (some s:Semaphore | t->s in signals)
}

pred inv10_correct_6[] {
all t : Track | t in succs.Junction implies t in signals.Semaphore
}

pred inv10_correct_7[] {
(succs.Junction) <: signals.Semaphore  = succs.Junction
}

pred inv10_correct_8[] {
all t: Track, j: Junction | j in t.succs => some s: Semaphore | s in t.signals
}

pred inv10_correct_9[] {
all t : Track | #(t.succs & Junction) > 0 implies # (t.signals & Semaphore) > 0
}

pred inv10_correct_10[] {
all t:Track | some Junction & t.succs implies some t.signals & Semaphore
}

pred inv10_correct_11[] {
all j : Junction, t : succs.j| some s:Semaphore | s in t.signals
}

pred inv10_correct_12[] {
all x : Track | some Junction & x.succs implies some Semaphore & x.signals
}

pred inv10_correct_13[] {
all t:Track | (some t2:Track | t->t2 in succs and t2 in Junction) implies (some s:Signal | t->s in signals and s in Semaphore)
}

pred inv10_correct_14[] {
all t:Track|  #(t.succs & Junction)>0 implies some (t.signals & Semaphore)
}

pred inv10_correct_15[] {
all t1,t2 : Track | t2 in t1.succs and t2 in Junction implies some t1.signals&Semaphore
}

pred inv10_correct_16[] {
all t:Track | all j:Junction | t->j in succs implies some s:Semaphore | t->s in signals
}

pred inv10_correct_17[] {
all t : Track | (some j : Junction | j in t.succs) implies (some s : Semaphore | s in t.signals)
}

pred inv10_correct_18[] {
all j : Junction, t : succs.j| some s:Signal | s in t.signals and s in Semaphore
}

pred inv10_correct_19[] {
all t : Track | t in succs.Junction implies some (t.signals & Semaphore)
}

pred inv10_correct_20[] {
all t:Track | not no Junction&t.succs implies not no t.signals&Semaphore
}

pred inv10_correct_21[] {
all t1:Track,t2:Track | t2 in t1.succs and one (Junction & t2) implies (some s:Semaphore | s in t1.signals)
}

pred inv10_correct_22[] {
all t : Track, j : Junction | j in t.succs implies some (Semaphore & t.signals)
}

pred inv10_correct_23[] {
succs.Junction in signals.Semaphore
}

pred inv10_correct_24[] {
all t: Track | some t.succs&Junction implies some Semaphore&t.signals
}

pred inv10_correct_25[] {
all t : succs.Junction | some t.signals & Semaphore
}

pred inv10_correct_26[] {
all t:Track, j:Junction | t in succs.j => some Semaphore & t.signals
}

pred inv10_correct_27[] {
all t : succs.Junction | some Semaphore & t.signals
}

pred inv10_correct_28[] {
all t: Track | some t & succs.Junction implies some t.signals & Semaphore
}

