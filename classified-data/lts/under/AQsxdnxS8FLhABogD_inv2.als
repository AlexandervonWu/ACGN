sig State {
        trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv2 {
all i1,i2 : Init | i1 = i2
}

pred inv2c {
	one Init
}

check correct { inv2 <=> inv2c}
pred under { inv2 and !inv2c}
pred over { !inv2 and inv2c}
run over 
run under 

