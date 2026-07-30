sig State {
        trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv7 {
all to: State | reachable[Init, to] => reachable[to, Init]
}

pred reachable[from, to: State]{
   	let rel = { s1, s2: State | some s1 -> Event -> s2 & trans } |
  		to in from.^rel
}
/*
The LTS is reversible, ie, from a reacheable state it is always possible 
to return to an initial state.
*/

pred inv7c {
	let ts = {s1,s2:State | some e:Event | s1->e->s2 in trans} | all s:Init.^ts | some i:Init | i in s.^ts
}

check correct { inv7 <=> inv7c}
pred under { inv7 and !inv7c}
pred over { !inv7 and inv7c}
run over 
run under 

