module alloy4fun_augmented_lts_inv6
trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv6_oracle[] {
State.trans.State = Event
}

pred inv6_correct_0[] {
State.(trans.State) = Event
}

pred inv6_correct_1[] {
Event = State.trans.State
}

pred inv6_correct_2[] {
Event in (State.trans).State
}

pred inv6_correct_3[] {
all e:Event | e in State.trans.State
}

pred inv6_correct_4[] {
all e:Event |some s,s1:State |  (s1->e->s) in trans
}

pred inv6_correct_5[] {
all e : Event | some (trans.State).e
}

pred inv6_correct_6[] {
all e: Event | some s: State| e in (s.trans).State
}

pred inv6_correct_7[] {
all e:Event | some s1,s2:State | s1->e->s2 in trans
}

pred inv6_correct_8[] {
all e:Event | some e.(State.trans)
}

pred inv6_correct_9[] {
all e:Event | some s:State | e in State.~(s.trans)
}

pred inv6_correct_10[] {
all e : Event | some s : State | some s.trans[e]
}

pred inv6_correct_11[] {
all e : Event | some State.trans.State <: e
}

pred inv6_correct_12[] {
all e : Event | some s : State  | e->s in State.trans
}

pred inv6_correct_13[] {
all e:Event | some e<:State.trans
}

pred inv6_correct_14[] {
all e: Event | some e.(univ.trans)
}

pred inv6_correct_15[] {
all e:Event | some (State.trans.State & e)
}

pred inv6_correct_16[] {
all e:Event | some s1,s2:State | e in s1.~(s2.trans)
}

pred inv6_correct_17[] {
all e : Event | some s1 : State | e in s1.trans.State
}

