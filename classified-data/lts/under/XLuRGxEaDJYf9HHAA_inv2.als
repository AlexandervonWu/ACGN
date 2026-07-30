sig State {
        trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv2 {
all s1,s2:State | s1 in Init and s2 in Init implies s1=s2
}

pred inv2c {
	one Init
}

check correct { inv2 <=> inv2c}
pred under { inv2 and !inv2c}
pred over { !inv2 and inv2c}
run over 
run under 

