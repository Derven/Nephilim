datum
	chemical_reaction
		name = null
		var/id = null
		var/result = null
		var/list/required_reagents = new/list()
		var/list/required_catalysts = new/list()
		var/list/required_stabilizers = new/list()
		// Both of these variables are mostly going to be used with Metroid cores - but if you want to, you can use them for other things
		var/atom/required_container = null // the container required for the reaction to happen
		var/required_other = 0 // an integer required for the reaction to happen
		var/volatility = 0 // KEEP THIS BELOW 10 FFS! 1 is 10% chance per mixing it will explode / 10 is a 100% chance, tho there is a random explosion size based on this.
		var/result_amount = 0

		proc
			on_reaction(var/datum/reagents/holder, var/created_volume)
				return

		homunculinus
			name = "homunculinus"
			id = "homunculinus"
			result = "homunculinus"
			required_reagents = list("nutriments" = 1, "milk" = 1)
			result_amount = 5

			on_reaction(var/datum/reagents/holder, var/created_volume)
				//var/location = holder.my_atom.loc
				//new /obj/homunculus(location)
				world << "PIZDEC"
				holder.clear_reagents()
				return