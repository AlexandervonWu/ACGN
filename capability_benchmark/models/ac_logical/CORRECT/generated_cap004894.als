sig File {
  	/* A file is potentially a link to other files. */
	link : set File
}
/* The set of files in the trash. */
sig Trash in File {}

/* The set of protected files. */
sig Protected in File {}

pred inv7 {
no link.Trash
}

pred inv7c {
	no File.link & Trash
}

check correct { inv7 <=> inv7c}
pred under { inv7 and !inv7c}
pred over { !inv7 and inv7c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004894 { not ((inv7 and ((no CapBenchA and some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA)) }
pred cap004894c { ((not ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA)) or (not (inv7 and ((no CapBenchA and some CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap004894 { cap004894 iff cap004894c }
check CapBenchEquivalent_cap004894 for 4
