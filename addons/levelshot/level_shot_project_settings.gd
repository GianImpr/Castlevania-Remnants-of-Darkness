@tool
class_name LevelshotProjectSettings
extends Object


const PROJECT_SETTING_IMG_SAVE_FOLDER_KEY = "levelshot/settings/image_save_folder"
const PROJECT_SETTING_IMG_SAVE_FOLDER_DEFAULT = "user://levelshots"


static func get_img_save_folder() -> String:
	if !ProjectSettings.has_setting(PROJECT_SETTING_IMG_SAVE_FOLDER_KEY):
		ProjectSettings.set_setting(PROJECT_SETTING_IMG_SAVE_FOLDER_KEY, PROJECT_SETTING_IMG_SAVE_FOLDER_DEFAULT)
	ProjectSettings.set_initial_value(PROJECT_SETTING_IMG_SAVE_FOLDER_KEY, PROJECT_SETTING_IMG_SAVE_FOLDER_DEFAULT)
	ProjectSettings.add_property_info(
		{
			"name": PROJECT_SETTING_IMG_SAVE_FOLDER_KEY,
			"type": TYPE_STRING
		}
	)

	return ProjectSettings.get_setting(PROJECT_SETTING_IMG_SAVE_FOLDER_KEY)
