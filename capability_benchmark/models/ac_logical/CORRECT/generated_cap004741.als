sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv2 {
File in Trash
}

pred inv2c {
	File in Trash
}

check correct { inv2 <=> inv2c}
pred under { inv2 and !inv2c}
pred over { !inv2 and inv2c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004741 { not ((inv2 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB)) and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap004741c { ((not ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) or (not (inv2 and ((some CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) or no CapBenchB)))) }
assert CapBenchEquivalent_cap004741 { cap004741 iff cap004741c }
check CapBenchEquivalent_cap004741 for 4
