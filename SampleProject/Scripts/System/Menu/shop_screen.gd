extends Control
class_name Shop

@export var initial_screen: Control
@export var buy_screen: Control
@export var sell_screen: Control
@export var description_panel: PanelContainer
@export var description_icon: TextureRect
@export var description_text: Label
static var displayed_gold: int

func _ready():
	initial_screen.process_mode = Node.PROCESS_MODE_DISABLED
	buy_screen.process_mode = Node.PROCESS_MODE_DISABLED
	sell_screen.process_mode = Node.PROCESS_MODE_DISABLED

### Opens the initial shop screen.
func startShop() -> void:
	return
	
### Opens the buy screen of the shop.
func openBuyMenu() -> void:
	return

### Opens the sell screen of the shop.
func openSellMenu() -> void:
	return

### Closes the buy screen of the shop, returning to the initial screen.
func closeBuyMenu() -> void:
	return

### Closes the sell screen of the shop, returning to the initial screen.
func closeSellMenu() -> void:
	return

### Closes the shop screen, returning to the game.
func closeShop() -> void:
	return
