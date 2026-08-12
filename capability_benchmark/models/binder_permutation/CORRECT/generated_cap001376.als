sig State {
        trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv1 {
all s: State | some s.trans
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

pred cap001376 { all x, y: CapBenchA | (x->y in capBenchR and (inv1 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some capBenchS))) }
pred cap001376c { all a, b: CapBenchA | (b->a in capBenchR and (inv1 and ((some CapBenchA and CapBenchA in CapBenchA + CapBenchB) or some capBenchS))) }
assert CapBenchEquivalent_cap001376 { cap001376 iff cap001376c }
check CapBenchEquivalent_cap001376 for 4
