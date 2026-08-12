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

pred cap005055 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA)) and ((some capBenchR and some capBenchR) or no CapBenchB))) }
pred cap005055c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchR and some capBenchR) or no CapBenchB)) or (not (inv1 and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA)))) }
assert CapBenchEquivalent_cap005055 { cap005055 iff cap005055c }
check CapBenchEquivalent_cap005055 for 4
