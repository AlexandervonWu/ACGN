module alloy4fun_augmented_lts_inv1
trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv1_oracle[] {
all s:State | some s.trans
}

pred inv1_correct_0[] {
trans.State.Event = State
}

pred inv1_correct_1[] {
no s:State | no s.trans
}

pred inv1_correct_2[] {
always (all s: State | some s.trans)
}

pred inv1_correct_3[] {
iden[State] in trans.State.Event
}

pred inv1_correct_4[] {
all s: State | some e: Event | some s.trans[e]
}

pred inv1_correct_5[] {
all x : State | some x.trans
}

pred inv1_correct_6[] {
all s : State | some Event.(s.trans)
}

pred inv1_correct_7[] {
trans in State -> some Event -> State
}

pred inv1_correct_8[] {
State = trans.State.Event
}

pred inv1_correct_9[] {
State in trans.State.Event
}

pred inv1_correct_10[] {
all s:State |some e:Event | e.(s.trans) != none
}

pred inv1_correct_11[] {
all s:State | some s.trans:>State
}

