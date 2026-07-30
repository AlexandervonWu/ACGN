sig State {
        trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv4 {
let rel = { s1, s2: State | some s1 -> Event -> s2 & trans } |
  		all s: State - Init | s in Init.*rel
}

pred inv4c {
	let ts = {s1,s2:State | some e:Event | s1->e->s2 in trans} | all s:State | some i:Init | s in i.^ts
}

check correct { inv4 <=> inv4c}
pred under { inv4 and !inv4c}
pred over { !inv4 and inv4c}
run over 
run under 

