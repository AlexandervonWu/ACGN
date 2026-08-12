sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv1 {
no Trash
}

pred inv1c {
	no Trash
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap000933 { ((inv1 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or capBenchR in (CapBenchA -> CapBenchA))) or ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some CapBenchB) or ((some capBenchR and some CapBenchB) or some capBenchR)) }
pred cap000933c { (((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and some CapBenchB) or ((some capBenchR and some CapBenchB) or some capBenchR) or (inv1 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap000933 { cap000933 iff cap000933c }
check CapBenchEquivalent_cap000933 for 4
