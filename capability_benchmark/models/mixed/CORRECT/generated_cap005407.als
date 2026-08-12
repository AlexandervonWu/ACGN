sig State {
        trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv6 {
all e : Event | some (trans.State).e
}

pred inv6c {
	State.trans.State = Event
}

check correct { inv6 <=> inv6c}
pred under { inv6 and !inv6c}
pred over { !inv6 and inv6c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap005407 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv6 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))) and ((some capBenchR and some CapBenchA) or some CapBenchB))) }
pred cap005407c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchR and some CapBenchA) or some CapBenchB)) or (not (inv6 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap005407 { cap005407 iff cap005407c }
check CapBenchEquivalent_cap005407 for 4
