sig State {
        trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv3 {
all x, z, v : State, y : Event  | x->y->z in trans and x->y->v in trans implies z=v
}

pred inv3c {
	all s : State, e : Event | lone e.(s.trans)
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 

