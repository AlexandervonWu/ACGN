sig State {
        trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv7 {
all s1,s2:State | some e1,e2:Event  | s1->e1->s2 in trans implies s2->e2->s1 in trans
}

pred inv7c {
	let ts = {s1,s2:State | some e:Event | s1->e->s2 in trans} | all s:Init.^ts | some i:Init | i in s.^ts
}

check correct { inv7 <=> inv7c}
pred under { inv7 and !inv7c}
pred over { !inv7 and inv7c}
run over 
run under 

