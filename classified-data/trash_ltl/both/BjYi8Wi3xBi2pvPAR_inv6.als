var sig File {
	var link : lone File
}
var sig Trash in File {}

var sig Protected in File {}

pred inv6 {
eventually some f:File | f not in File' and always f not in File'
}

pred inv6c {
	always Trash in Trash'
}

check correct { inv6 <=> inv6c}
pred under { inv6 and !inv6c}
pred over { !inv6 and inv6c}
run over 
run under 


