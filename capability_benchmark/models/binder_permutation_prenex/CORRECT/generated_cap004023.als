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

pred cap004023 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv6 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some CapBenchA))) }
pred cap004023c { some a, b: CapBenchA | (b->a in capBenchR and (inv6 and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchA) and some CapBenchA))) }
assert CapBenchEquivalent_cap004023 { cap004023 iff cap004023c }
check CapBenchEquivalent_cap004023 for 4
