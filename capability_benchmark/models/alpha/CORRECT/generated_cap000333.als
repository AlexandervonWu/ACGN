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

pred cap000333 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv6 and ((some capBenchS or some CapBenchB) or some capBenchS))) }
pred cap000333c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv6 and ((some capBenchS or some CapBenchB) or some capBenchS))) }
assert CapBenchEquivalent_cap000333 { cap000333 iff cap000333c }
check CapBenchEquivalent_cap000333 for 4
