module alloy4fun_augmented_lts_inv7
trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv7_oracle[] {
let ts = {s1,s2:State | some e:Event | s1->e->s2 in trans} | all s:Init.^ts | some i:Init | i in s.^ts
}

pred inv7_correct_0[] {
all s: State | s in Init.^{s1, s2: State | some s1.trans.s2} implies some (Init & s.^{s1, s2: State | some s1.trans.s2})
}

pred inv7_correct_1[] {
let t = {x: State, y: State | some (x.trans).y } |
  	all s: Init.^t | some s.^t & Init
}

pred inv7_correct_2[] {
let adj = {s1,s2: State | some e: Event | s1 -> e -> s2 in trans} |
  all r: Init.^adj | some i: Init | i in r.^adj
}

pred inv7_correct_3[] {
let adj ={x,y:State | some e:Event |x->e->y in trans} |
  
    all s:(Init.^adj) | some ( s.^adj & Init )
}

