cap pr drop Table
program define Table
syntax [anything(everything)], [MOVED(string asis)] [*]
	cap estimates drop quipu*
	qui Use `anything', moved(`"`moved'"')
	forv i=1/`c(N)' {
		local fn = path[`i'] +"/"+filename[`i']
		estimates use "`fn'"
		estimates title: "`fn'"
		estimates store quipu`i', nocopy
	}
	clear
	estimates table _all , `options'
	estimates drop quipu*
end

