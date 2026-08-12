sig State {
        trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv1 {
all s : State | some s.trans
}

pred inv1c {
	all s:State | some s.trans
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001098 { all x, y: CapBenchA | (x->y in capBenchR and (inv1 and ((no CapBenchA and some capBenchR) and some CapBenchB))) }
pred cap001098c { all a, b: CapBenchA | (b->a in capBenchR and (inv1 and ((no CapBenchA and some capBenchR) and some CapBenchB))) }
assert CapBenchEquivalent_cap001098 { cap001098 iff cap001098c }
check CapBenchEquivalent_cap001098 for 4
