sig State {
        trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv2 {
all s : State | one i : Init | i in s
}

pred inv2c {
	one Init
}

check correct { inv2 <=> inv2c}
pred under { inv2 and !inv2c}
pred over { !inv2 and inv2c}
run over 
run under 

