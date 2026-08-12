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

pred cap004354 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv6 and ((no CapBenchA and some capBenchR) and some capBenchS))) }
pred cap004354c { some a, b: CapBenchA | (b->a in capBenchR and (inv6 and ((no CapBenchA and some capBenchR) and some capBenchS))) }
assert CapBenchEquivalent_cap004354 { cap004354 iff cap004354c }
check CapBenchEquivalent_cap004354 for 4
