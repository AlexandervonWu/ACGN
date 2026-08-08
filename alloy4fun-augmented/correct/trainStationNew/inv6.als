module alloy4fun_augmented_trainStationNew_inv6
succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv6_oracle[] {
all t : Entry | some t.signals & Speed
}

pred inv6_correct_0[] {
all e :Entry | some s : Speed | s in e.signals
}

pred inv6_correct_1[] {
all t: Entry | some s: Speed | s in t.signals
}

pred inv6_correct_2[] {
all e:Track | e in Entry implies some s:Signal | e->s in signals and s in Speed
}

pred inv6_correct_3[] {
all e: Entry | some (Speed & e.signals)
}

pred inv6_correct_4[] {
all e : Entry | some (e.signals & Speed)
}

pred inv6_correct_5[] {
all t:Track | t in Entry implies some s:Speed | s in t.signals
}

pred inv6_correct_6[] {
all e : Entry | some sp : Speed | sp in e.signals
}

pred inv6_correct_7[] {
all entry : univ | entry in Entry implies some speed : Speed | entry->speed in signals
}

pred inv6_correct_8[] {
all x:Entry | some y: Speed | x->y in signals
}

pred inv6_correct_9[] {
all e:Entry | some s:Speed | e->s in signals
}

pred inv6_correct_10[] {
Entry in signals.Speed
}

pred inv6_correct_11[] {
all t:Entry | #t.signals&Speed>0
}

pred inv6_correct_12[] {
all t:Track | one (Entry & t) implies (some s:Speed | s in t.signals)
}

pred inv6_correct_13[] {
all t:Entry| some s:Speed| t->s in signals
}

pred inv6_correct_14[] {
all e : Entry | some s : Speed | some e.signals & s
}

pred inv6_correct_15[] {
all x : Entry | some y:Speed| y in x.signals
}

pred inv6_correct_16[] {
all t:Entry | some s:Signal | s in t.signals and s in Speed
}

pred inv6_correct_17[] {
all e:Entry | some s:Signal | e->s in signals and s in Speed
}

pred inv6_correct_18[] {
all t:Track & Entry | some s:Speed| s in t.signals
}

pred inv6_correct_19[] {
all entry : Entry | some s : Speed| s in entry.signals
}

pred inv6_correct_20[] {
all t: Track | t in Entry implies some t.signals&Speed
}

pred inv6_correct_21[] {
all t : Entry | some s : t.signals | s in Speed
}

pred inv6_correct_22[] {
all t: Track | t in Entry implies some Speed&t.signals
}

pred inv6_correct_23[] {
all en : Entry | some s : Speed | s in en.signals
}

pred inv6_correct_24[] {
all x:Track | x in Entry => some (x.signals & Speed)
}

pred inv6_correct_25[] {
all x : Entry | some Speed & x.signals
}

pred inv6_correct_26[] {
all x: Entry | some y: x.signals | y in Speed
}

