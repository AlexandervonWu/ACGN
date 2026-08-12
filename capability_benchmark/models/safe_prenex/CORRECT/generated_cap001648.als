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

pred cap001648 { ((some x: CapBenchA | x->x in capBenchR) and (inv3 and ((some capBenchR and no CapBenchA) or no CapBenchA))) }
pred cap001648c { (some x: CapBenchA | (x->x in capBenchR and (inv3 and ((some capBenchR and no CapBenchA) or no CapBenchA)))) }
assert CapBenchEquivalent_cap001648 { cap001648 iff cap001648c }
check CapBenchEquivalent_cap001648 for 4
