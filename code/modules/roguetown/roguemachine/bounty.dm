/obj/structure/roguemachine/bounty
	name = "Excidium"
	desc = ""
	icon = 'icons/roguetown/misc/machines.dmi'
	icon_state = "atm-b" // TODO: change this
	density = FALSE
	blade_dulling = DULLING_BASH

	/// List of all created and non-completed bounties
	var/list/bounties = list()

/datum/bounty
	var/target
	var/amount
	var/reason

///Shows all active bounties to the user.
/obj/structure/roguemachine/bounty/proc/consult_bounties()

	// Empty?
	if(bounties.len == 0)
		say("No bounties are currently active.")
		return

	// List all bounties
	for(var/datum/bounty/saved_bounty in bounties)
		say("A bounty of [saved_bounty.amount] mammons has been put on [saved_bounty.target] for '[saved_bounty.reason]'.")


///Sets a bounty on a target player through user input.
///@param user: The player setting the bounty.
/obj/structure/roguemachine/bounty/proc/set_bounty(var/mob/living/carbon/human/user)
	var/list/eligible_players = list()
	for(var/mob/living/H in GLOB.player_list)
		if(H.client)
			//if(H != user)
			eligible_players += H.real_name
		
	var/target = input(user, "Whose name shall be etched on the wanted list?", src) as null|anything in eligible_players
	if(isnull(target))
		say("No target selected.")
		return

	var/amount = input(user, "How many mammons shall be stained red for their demise?", src) as null|num
	if(isnull(amount) || amount < 1)
		say("Invalid amount.")
		return

	// Has user a bank account?
	if(!(user in SStreasury.bank_accounts))
		say("You have no bank account.")
		return

	// Has user enough money?
	if(SStreasury.bank_accounts[user] < amount)
		say("Insufficient balance funds.")
		return

	var/reason = input(user, "For what sins do you summon the hounds of hell?", src) as null|text
	if(isnull(reason) || reason == "")
		say("No reason given.")
		return

	var/confirm = input(user, "Do you dare unleash this darkness upon the world?", src) as null|anything in list("Yes", "No")	
	if(isnull(confirm) || confirm == "No") return

	// Deduct money from user
	SStreasury.bank_accounts[user] -= round(amount)

	// Finally create bounty
	var/datum/bounty/new_bounty = new /datum/bounty
	new_bounty.amount = round(amount)
	new_bounty.target = target
	new_bounty.reason = reason
	bounties += new_bounty
	say("The bounty has been set.")
	playsound(src, 'sound/misc/machinetalk.ogg', 100, FALSE, -1)

/obj/structure/roguemachine/bounty/attack_hand(mob/user)
	if(!ishuman(user)) return

	// We need to check the user's bank account later
	var/mob/living/carbon/human/H = user

	// menu will look like this:
	// 1. Consult bounties
	// 2. Create bounty

	//TODO: Should bounties on the same person stack up or be separate?

	// Main Menu
	var/list/choices = list("Consult bounties", "Set bounty")
	var/selection = input(user, "The Excidium listens", src) as null|anything in choices

	switch(selection)

		if("Consult bounties")
			consult_bounties()

		if("Set bounty")
			set_bounty(H)

/obj/structure/roguemachine/bounty/attackby(obj/item/P, mob/user, params)

	if(!(ishuman(user))) return

	// Only heads are allowed
	if(P.type != /obj/item/bodypart/head) return

	// Save the head in case it's not the right one
	var/obj/item/bodypart/head/stored_head = P
	var/correct_head = FALSE

	qdel(P)
	//TODO: add nom nom sounds
	var/random_say = rand(1, 3)
	if(random_say == 1)
		say("Commencing cephalic dissection...")
	else if(random_say == 2)
		say("Analyzing skull structure...")
	else
		say("Performing intra-cranial inspection...")
	sleep(3 SECONDS)
	for(var/datum/bounty/b in bounties)
		if(b.target == stored_head.real_name)
			correct_head = TRUE
			say("I have been sated.")
			playsound(src, 'sound/misc/machinetalk.ogg', 100, FALSE, -1) 
		//TODO: give out reward

	// No valid bounty for this head?
	if(correct_head == FALSE)
		say("This skull carries no price.")
		playsound(src, 'sound/misc/machineno.ogg', 100, FALSE, -1)
		stored_head.forceMove(src.loc)
		//spawn(stored_head)



