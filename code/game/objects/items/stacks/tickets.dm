/obj/item/stack/arcadeticket
	name = "arcade tickets"
	desc = "Wow! With enough of these, you could buy a bike! ...Pssh, yeah right."
	singular_name = "arcade ticket"
	icon_state = "arcade-ticket"
	inhand_icon_state = "tickets"
	w_class = WEIGHT_CLASS_TINY
	max_amount = 30
	merge_type = /obj/item/stack/arcadeticket

/obj/item/stack/arcadeticket/Initialize(mapload, new_amount, merge = TRUE)
	. = ..()
	update_icon()

/obj/item/stack/arcadeticket/update_icon()
	var/amount = get_amount()
	if((amount >= 12) && (amount > 0))
		icon_state = "arcade-ticket_4"
	else if((amount >= 6) && (amount > 0))
		icon_state = "arcade-ticket_3"
	else if((amount >= 2) && (amount > 0))
		icon_state = "arcade-ticket_2"
	else
		icon_state = "arcade-ticket"

/obj/item/stack/arcadeticket/proc/pay_tickets()
	amount -= 2
	if (amount == 0)
		qdel(src)

/obj/item/stack/arcadeticket/thirty
	amount = 30
