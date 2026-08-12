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

pred cap004281 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv6 and ((some CapBenchB or no CapBenchB) or some capBenchR))) }
pred cap004281c { some a, b: CapBenchA | (b->a in capBenchR and (inv6 and ((some CapBenchB or no CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap004281 { cap004281 iff cap004281c }
check CapBenchEquivalent_cap004281 for 4
