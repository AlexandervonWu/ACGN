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

pred cap003050 { all x: CapBenchA | (x->x in capBenchR and (inv3 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA)) and ((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and no CapBenchB)) }
pred cap003050c { all renamed: CapBenchA | (((CapBenchA in CapBenchA + CapBenchB or no CapBenchB) and no CapBenchB) and renamed->renamed in capBenchR and (inv3 and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA))) }
assert CapBenchEquivalent_cap003050 { cap003050 iff cap003050c }
check CapBenchEquivalent_cap003050 for 4
