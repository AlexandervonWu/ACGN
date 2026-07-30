sig State {
        trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv2 {
one State && all s:State | no s.trans
}

pred inv2c {
	one Init
}

check correct { inv2 <=> inv2c}
pred under { inv2 and !inv2c}
pred over { !inv2 and inv2c}
run over 
run under 

