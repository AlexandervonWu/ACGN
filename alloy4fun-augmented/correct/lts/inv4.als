module alloy4fun_augmented_lts_inv4
trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv4_oracle[] {
let ts = {s1,s2:State | some e:Event | s1->e->s2 in trans} | all s:State | some i:Init | s in i.^ts
}

pred inv4_correct_0[] {
State in Init.(^onlyStates)
}

pred inv4_correct_1[] {
Init.^{x,y: State | some (x.trans).y} = State
}

pred inv4_correct_2[] {
let adj = { s1, s2 : State | some e : Event | s1->e->s2 in trans} | State in Init.^adj
}

pred inv4_correct_3[] {
State = Init.(^onlyStates)
}

pred inv4_correct_4[] {
let t = {x,y : State | some z : Event | x->z->y in trans} |
	State in Init.(^t)
}

pred inv4_correct_5[] {
Init.^({x: State, y: State | some (x.trans).y }) = State
}

pred inv4_correct_6[] {
Init.^{s1, s2: State | some s1.trans.s2} = State
}

pred inv4_correct_7[] {
let adj = {s1,s2: State | some e: Event | s1 -> e -> s2 in trans} |
  all s: State | some i: Init | s in i.^adj
}

pred inv4_correct_8[] {
let trans_bin = {s1, s2 : State | some s1.trans.s2} |
    Init.^trans_bin = State
}

pred inv4_correct_9[] {
let trans2 = {s1, s2 : State | some s1.trans.s2} |
    Init.^trans2 = State
}

pred inv4_correct_10[] {
let t = { s1,s2 : State | some e : Event | s1->e->s2  in trans } |
  	State in Init.(^t)
}

pred inv4_correct_11[] {
let adj = {x,y: State | some (x.trans).y} | State in Init.^adj
}

pred inv4_correct_12[] {
let rel = { s1, s2: State | some s1 -> Event -> s2 & trans } |
  		all s: State | s in Init.^rel
}

pred inv4_correct_13[] {
let t = { x : State, y : State | some e : Event | x->e->y in trans} |
  State in Init.(^t)
}

pred inv4_correct_14[] {
let rel = { s1, s2: State | some s1 -> Event -> s2 & trans } |
  		State in Init.^rel
}

pred inv4_correct_15[] {
all s : State | Init.^{x,y : State | some x.trans.y} = State
}

pred inv4_correct_16[] {
all s : State | s in Init.trans[Event] + Init.trans[Event].trans[Event] + Init.trans[Event].trans[Event].trans[Event]
}

pred inv4_correct_17[] {
State = Init.~(^onlyStates)
}

pred inv4_correct_18[] {
let t = { x : State, y : State | some e : Event | x->e->y in trans} |
  all s:State | s in  Init.(^t)
}

pred inv4_correct_19[] {
State in Init.^{s1, s2: State | s2 in s1.trans[Event]}
}

pred inv4_correct_20[] {
State in Event.(Init.trans) + Event.((Event.(Init.trans)).trans) + Event.((Event.((Event.(Init.trans)).trans)).trans)
}

pred inv4_correct_21[] {
let adj ={x,y:State | some e:Event |x->e->y in trans} |
  
 (State) in Init.^adj
}

pred inv4_correct_22[] {
State in Init.(^{s1,s2 : State | some e : Event | s1->e->s2  in trans})
}

pred inv4_correct_23[] {
let t = { x : State, y : State | some e : Event | x->e->y in trans} |
  all s:State | some i:Init | s in  i.(^t)
}

pred inv4_correct_24[] {
State in Init.(^{ x : State, y : State | some e : Event | x->e->y in trans})
}

