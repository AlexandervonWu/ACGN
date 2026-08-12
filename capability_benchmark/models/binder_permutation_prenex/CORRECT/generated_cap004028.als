sig State {
        trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv3 {
all s,s1,s2:State,e:Event | s->e->s1 in trans and s->e->s2 in trans implies s1=s2
}

pred inv3c {
	all s : State, e : Event | lone e.(s.trans)
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004028 { ((some x, y: CapBenchA | x->y in capBenchR) and (inv3 and ((some capBenchR and no CapBenchB) or some CapBenchA))) }
pred cap004028c { some a, b: CapBenchA | (b->a in capBenchR and (inv3 and ((some capBenchR and no CapBenchB) or some CapBenchA))) }
assert CapBenchEquivalent_cap004028 { cap004028 iff cap004028c }
check CapBenchEquivalent_cap004028 for 4
