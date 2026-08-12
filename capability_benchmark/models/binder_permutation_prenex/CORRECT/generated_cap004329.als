sig State {
        trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv6 {
all e:Event | some s1,s2:State | s1->e->s2 in trans
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

pred cap004329 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv6 and ((some CapBenchB or some CapBenchB) or some capBenchS))) }
pred cap004329c { some a, b: CapBenchA | (b->a in capBenchR and (inv6 and ((some CapBenchB or some CapBenchB) or some capBenchS))) }
assert CapBenchEquivalent_cap004329 { cap004329 iff cap004329c }
check CapBenchEquivalent_cap004329 for 4
