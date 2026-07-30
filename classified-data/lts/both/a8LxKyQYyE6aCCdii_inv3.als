sig State {
        trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv3 {
all s : State {
    	all disj e1,e2 : Event | some s.trans[e1] implies no s.trans[e2]
    }
}

pred inv3c {
	all s : State, e : Event | lone e.(s.trans)
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 

