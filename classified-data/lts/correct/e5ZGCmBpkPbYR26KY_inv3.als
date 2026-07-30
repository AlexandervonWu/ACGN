sig State {
        trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv3 {
all s : State, e : Event | lone e.(s.trans)  
}

fun adj : State -> State {
	{x, y : State | some e : Event | x -> e -> y in trans}
}

pred inv3c {
	all s : State, e : Event | lone e.(s.trans)
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 

