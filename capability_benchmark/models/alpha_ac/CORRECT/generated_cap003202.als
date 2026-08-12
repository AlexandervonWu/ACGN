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

pred cap003202 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((no CapBenchA and some CapBenchB) and no CapBenchB)) and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS)) }
pred cap003202c { all renamed: CapBenchA | (((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS) and renamed->renamed in capBenchR and (inv1 and ((no CapBenchA and some CapBenchB) and no CapBenchB))) }
assert CapBenchEquivalent_cap003202 { cap003202 iff cap003202c }
check CapBenchEquivalent_cap003202 for 4
