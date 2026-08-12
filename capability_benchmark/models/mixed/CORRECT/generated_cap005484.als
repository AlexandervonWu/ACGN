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

pred cap005484 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv6 and ((some capBenchR and some capBenchR) or CapBenchA in CapBenchA + CapBenchB)) and ((some CapBenchB or no CapBenchA) or no CapBenchA))) }
pred cap005484c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some CapBenchB or no CapBenchA) or no CapBenchA)) or (not (inv6 and ((some capBenchR and some capBenchR) or CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap005484 { cap005484 iff cap005484c }
check CapBenchEquivalent_cap005484 for 4
