sig State {
        trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv1 {
all s1, s2:State | some e:Event | (s1->e->s2 in trans and s1 != s2)
}

pred inv1c {
	all s:State | some s.trans
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 

