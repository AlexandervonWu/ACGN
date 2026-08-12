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

pred cap004580 { not ((inv3 and ((some CapBenchA and no CapBenchA) or some CapBenchB)) and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or no CapBenchB)) }
pred cap004580c { ((not ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or no CapBenchB)) or (not (inv3 and ((some CapBenchA and no CapBenchA) or some CapBenchB)))) }
assert CapBenchEquivalent_cap004580 { cap004580 iff cap004580c }
check CapBenchEquivalent_cap004580 for 4
