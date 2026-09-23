@tool
extends AcceptDialog


@onready var _shameless_plug: RichTextLabel = %ShamelessPlug


const EDITOR_ONLY_PLACEHOLDER := "$EDITORONLY$"


func _ready() -> void:
	_shameless_plug.meta_clicked.connect(_on_shameless_plug_meta_clicked)
	if not Engine.is_editor_hint():
		_shameless_plug.text = _shameless_plug.text.substr(0, _shameless_plug.text.find(EDITOR_ONLY_PLACEHOLDER))
	else:
		_shameless_plug.text = _shameless_plug.text.replace(EDITOR_ONLY_PLACEHOLDER, "")


func _on_shameless_plug_meta_clicked(meta: Variant) -> void:
	# Open clicked URLs.
	OS.shell_open(str(meta))
