sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv3 {
some Trash
}

pred inv3c {
	some Trash 
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004756 { not ((inv3 and ((some CapBenchA and some CapBenchA) or some capBenchR)) and ((some capBenchS or some capBenchS) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap004756c { ((not ((some capBenchS or some capBenchS) or capBenchR in (CapBenchA -> CapBenchA))) or (not (inv3 and ((some CapBenchA and some CapBenchA) or some capBenchR)))) }
assert CapBenchEquivalent_cap004756 { cap004756 iff cap004756c }
check CapBenchEquivalent_cap004756 for 4
