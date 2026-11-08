@tool
extends OptionButton

var value: int:
	get:
		return get_selected_id()
	set(r):
		if r == -1:
			select(0)
		else:
			select(get_item_index(r))
