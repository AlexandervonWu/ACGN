module alloy4fun_augmented_lts_inv5
trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv5_oracle[] {
all s1,s2:State | s1.trans.State = s2.trans.State
}

pred inv5_correct_0[] {
all s, ss: State | s.trans.State = ss.trans.State
}

pred inv5_correct_1[] {
all s1, s2 : State | State.(~(s1.trans)) = State.(~(s2.trans))
}

pred inv5_correct_2[] {
all x: State, y: State | (x.trans).univ = (y.trans).univ
}

pred inv5_correct_3[] {
all s, s1 : State | (s.trans).State = (s1.trans).State
}

pred inv5_correct_4[] {
all s1,s2:State,e:Event | some e.(s1.trans) implies some e.(s2.trans)
}

pred inv5_correct_5[] {
all s1, s2: State | s1.(trans.State) = s2.(trans.State)
}

pred inv5_correct_6[] {
all s:State, s1:State | s.trans.State = s1.trans.State
}

pred inv5_correct_7[] {
all s : State | s.trans.State = State.trans.State
}

pred inv5_correct_8[] {
all disj s1,s2 :State |  no ((s1.trans).State) -((s2.trans).State) and no ((s2.trans).State) - ((s1.trans).State)
}

pred inv5_correct_9[] {
all s,r :State | (r.trans).State = (s.trans).State
}

pred inv5_correct_10[] {
all disj s, ss: State | s.trans.State = ss.trans.State
}

pred inv5_correct_11[] {
all s,r : State | (s.trans).State = (r.trans).State
}

pred inv5_correct_12[] {
all s : State | (State.trans).State = (s.trans).State
}

pred inv5_correct_13[] {
all s : State | s.(trans.State) = State.(trans.State)
}

pred inv5_correct_14[] {
all s,s1:State|  no( (s.trans).State  -  (s1.trans).State   )
}

pred inv5_correct_15[] {
all s, m: State, e: Event | some s.trans[e] => some m.trans[e]
}

pred inv5_correct_16[] {
all disj s,t:State | s.trans.State = t.trans.State
}

pred inv5_correct_17[] {
not some disj s1, s2:State | (s1.trans).State != (s2.trans).State
}

pred inv5_correct_18[] {
all disj s, s1 : State | (s.trans).State = (s1.trans).State
}

pred inv5_correct_19[] {
all disj s1, s2 : State | State.~(s1.trans) = State.~(s2.trans)
}

