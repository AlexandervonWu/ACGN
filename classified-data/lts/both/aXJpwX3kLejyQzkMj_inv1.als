sig State {
        trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv1 {
lone State.trans
}

pred inv1c {
	all s:State | some s.trans
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 

