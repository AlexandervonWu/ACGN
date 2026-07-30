sig State {
        trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv4 {
all i : Init | i.^{s1, s2 : State | s1->Event->s2 in trans} = State
}

pred inv4c {
	let ts = {s1,s2:State | some e:Event | s1->e->s2 in trans} | all s:State | some i:Init | s in i.^ts
}

check correct { inv4 <=> inv4c}
pred under { inv4 and !inv4c}
pred over { !inv4 and inv4c}
run over 
run under 

