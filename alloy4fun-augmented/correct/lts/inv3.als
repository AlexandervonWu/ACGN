module alloy4fun_augmented_lts_inv3
trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv3_oracle[] {
all s : State, e : Event | lone e.(s.trans)
}

pred inv3_correct_0[] {
all s: State | all e: Event | lone s.trans[e]
}

pred inv3_correct_1[] {
all e:Event, s:State | lone e.(s.trans)
}

pred inv3_correct_2[] {
all s,s1,s2:State,e:Event | s->e->s1 in trans and s->e->s2 in trans implies s1=s2
}

pred inv3_correct_3[] {
all e : Event, s : State | lone e<:s.trans
}

pred inv3_correct_4[] {
all s: State | all e : Event | lone n: State | e->n in s.trans
}

pred inv3_correct_5[] {
all x : State, y : Event | lone y.(x.trans)
}

pred inv3_correct_6[] {
all s: State | ~(s.trans).(s.trans) in iden
}

pred inv3_correct_7[] {
all x, z, v : State, y : Event  | x->y->z in trans and x->y->v in trans implies z=v
}

pred inv3_correct_8[] {
all s:State , e:Event| lone e->State & s.trans
}

pred inv3_correct_9[] {
all y : State, e : Event | lone e.(y.trans)
}

pred inv3_correct_10[] {
all e: Event | all s: State | lone s.trans[e]
}

pred inv3_correct_11[] {
all s: State, e: Event | lone ~(s.trans).e
}

pred inv3_correct_12[] {
all s:State, e:Event | lone e <: s.trans
}

