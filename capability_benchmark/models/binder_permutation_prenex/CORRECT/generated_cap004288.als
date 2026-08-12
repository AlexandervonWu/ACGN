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

pred cap004288 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv1 and ((some CapBenchA and some capBenchR) or some capBenchR))) }
pred cap004288c { some a, b: CapBenchA | (b->a in capBenchR and (inv1 and ((some CapBenchA and some capBenchR) or some capBenchR))) }
assert CapBenchEquivalent_cap004288 { cap004288 iff cap004288c }
check CapBenchEquivalent_cap004288 for 4
