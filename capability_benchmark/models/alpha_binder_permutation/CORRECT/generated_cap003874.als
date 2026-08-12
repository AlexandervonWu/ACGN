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

pred cap003874 { all x, y: CapBenchA | (x->y in capBenchR and (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS))) }
pred cap003874c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and some capBenchS))) }
assert CapBenchEquivalent_cap003874 { cap003874 iff cap003874c }
check CapBenchEquivalent_cap003874 for 4
