* Run this after a command, or together with <prefix : cmd>
* [SYNTAX 1] estdb add, notes(..) [prefix(..)] // after estdb setpath ..
* [SYNTAX 2] estdb add, notes(..) filename(..)

cap pr drop Add
program define Add, eclass
	
	* Parse (with our without colon)
	cap _on_colon_parse `0' // * See help _prefix
	if !_rc {
		local cmd `s(after)'
		local 0 `s(before)'
	}
	syntax , [PREFIX(string) FILENAME(string)] [NOTEs(string)]
	local has_filename = ("`filename'"!="")
	local has_prefix = ("`prefix'"!="")
	assert `has_filename' + `has_prefix' < 2, msg("Can't set prefix() and filename() at the same time!")

	`cmd' // Run command (if using prefix version)
	mata: st_local("notes", strtrim(`"`notes'"')) // trim (supports large strings)

	* Get or create filename
	if !`has_filename' {
		local path $estdb_path
		assert_msg `"`path'"'!="",  msg("Don't know where to save the .sest file! Use -estdb setpath PATH- to set the global estdb_path") rc(101)
		* Make up a filename
		assert_msg `"`e(cmdline)'"'!="", msg("No estimates found; e(cmdline) is empty")
		mata: st_local("cmd_hash", strofreal(hash1(`"`e(cmdline)'"', 1e8), "%30.0f"))
		mata: st_local("obs_hash", strofreal(hash1("`c(N)'", 1e4), "%30.0f"))
		if `"`notes'"'!="" {
			mata: st_local("notes_hash", strofreal(hash1(`"`notes'"', 1e4), "%30.0f"))
			local notes_hash "`notes_hash'-"
		}
		if ("`prefix'"!="")  {
			local fn_prefix "`prefix'_"
		}
		local filename "`path'/`fn_prefix'`obs_hash'-`notes_hash'`cmd_hash'.ster"
		
	}

	if ("`filename'"=="") {
asd
	}   

	* File either exists and will be replaced or doesnt' exist and will be created
	cap conf new file "`filename'"
	if (_rc) qui conf file "`filename'"

	* Parse key=value options and append to ereturn as hidden
	if `"`notes'"'!="" {
		local keys
		while `"`notes'"'!="" {
			gettoken key notes : notes, parse(" =")
			assert "`key'"!="sample" // Else -estimates- will fail
			gettoken _ notes : notes, parse("=")
			gettoken value notes : notes, quotes
			local keys `keys' `key'
			ereturn hidden local `key' `value'
		}
		ereturn hidden local keys `keys'

		ereturn hidden local ivreg2_firsteqs
		ereturn hidden local first_prefix
	}

	* FOR EACH OPT IN OPTIONS SAVE, run estimates note: key value
	estimates save "`filename'", replace

end
