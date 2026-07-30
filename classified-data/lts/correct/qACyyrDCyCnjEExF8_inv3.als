sig State {
        trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv3 {
all s : State, e : Event | lone s.trans[e]
}

fun tr : State -> State { { s1, s2 : State | s1->Event->s2 in trans }
}

pred inv3c {
	all s : State, e : Event | lone e.(s.trans)
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 

