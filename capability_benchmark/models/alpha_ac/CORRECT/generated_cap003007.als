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

pred cap003007 { all x: CapBenchA | (x->x in capBenchR and (inv1 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some CapBenchA)) and ((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA)) }
pred cap003007c { all renamed: CapBenchA | (((some capBenchR and capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchA) and renamed->renamed in capBenchR and (inv1 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchA) and some CapBenchA))) }
assert CapBenchEquivalent_cap003007 { cap003007 iff cap003007c }
check CapBenchEquivalent_cap003007 for 4
