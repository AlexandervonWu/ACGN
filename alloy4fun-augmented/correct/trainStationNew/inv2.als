module alloy4fun_augmented_trainStationNew_inv2
succs : set Track,
	signals : set Signal
}
sig Junction, Entry, Exit in Track {}

sig Signal {}
sig Semaphore, Speed extends Signal {}

pred inv2_oracle[] {
all s : Signal | one signals.s
}

pred inv2_correct_0[] {
all s:Signal | one t:Track | s in t.signals
}

pred inv2_correct_1[] {
all x:Signal| one signals.x
}

pred inv2_correct_2[] {
all s:Signal | one t:Track |  t->s in signals
}

pred inv2_correct_3[] {
all x : Signal | some t : Track | x in t.signals and no x & (Track-t).signals
}

pred inv2_correct_4[] {
all s: Signal | s in Track.signals
all s: Signal | all t,t1 : Track | s in t.signals and s in t1.signals implies t=t1
}

pred inv2_correct_5[] {
signals in Track one -> Signal
}

pred inv2_correct_6[] {
all s : Signal | one t : Track | one signals.s & t
}

pred inv2_correct_7[] {
all c:Signal | one t:Track | c in t.signals
}

pred inv2_correct_8[] {
no (Signal - Track.signals)
all t,u : Track | t != u implies no (t.signals & u.signals)
}

pred inv2_correct_9[] {
all sinal : univ | sinal in Signal implies one track : Track | track->sinal in signals
}

pred inv2_correct_10[] {
all si:Signal | one t:Track | si in t.signals
}

pred inv2_correct_11[] {
all s : Signal | one s.~signals
}

pred inv2_correct_12[] {
all sign : Signal | one tr : Track | sign in tr.signals
}

pred inv2_correct_13[] {
all s : Signal | lone signals.s
Signal in Track.signals
}

pred inv2_correct_14[] {
all s:Signal | one t1:Track | t1->s in signals
}

pred inv2_correct_15[] {
all x : Signal | one y : Track | x in y.signals
}

pred inv2_correct_16[] {
all si : Signal | one signals.si
}

pred inv2_correct_17[] {
all a1,a2:Track | (some b:Signal | a1->b in signals and a2->b in signals) implies a1 = a2
all b:Signal | some a:Track | a->b in signals
}

pred inv2_correct_18[] {
all s : Signal | one x : Track | s in x.signals
}

pred inv2_correct_19[] {
all s : Signal | one t : Track | s in t.signals and s not in (Track - t).signals
}

pred inv2_correct_20[] {
all a : Signal | one b : Track | b -> a in signals
}

pred inv2_correct_21[] {
all s:Signal | #signals.s=1
}

pred inv2_correct_22[] {
all signal: Signal | one track:Track | signal in track.signals
}

pred inv2_correct_23[] {
all s: Signal, t1,t2 : Track | t1->s in signals and t2->s in signals implies t1=t2
all s : Signal | some t : Track | t->s in signals
}

pred inv2_correct_24[] {
all s : Signal | one t : Track | t in signals.s
}

pred inv2_correct_25[] {
all s: Signal| some t: Track| one signals.s
}

pred inv2_correct_26[] {
all s : Signal | all t1, t2 : Track | s in t1.signals and s in t2.signals implies t1 = t2
all s : Signal | some t : Track | s in t.signals
}

pred inv2_correct_27[] {
no (Signal - Track.signals)
all s : Signal | lone signals.s
}

pred inv2_correct_28[] {
all x : Signal | #signals.x = 1
}

pred inv2_correct_29[] {
Signal = Track.signals
all s : Signal | lone s.~signals
}

