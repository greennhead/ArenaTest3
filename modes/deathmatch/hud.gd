extends CanvasLayer
@onready var hudText: Label = $CenterContainer/hudPlate/hudText
@onready var hudPlate: TextureRect = $CenterContainer/hudPlate
@onready var hudFace: Sprite2D = $CenterContainer/hudPlate/hudFace
@onready var centerContainer: CenterContainer = $CenterContainer

@onready var hudText2: Label = $CenterContainer/hudPlate/hudText2


func getMostUsedColor(img : Texture2D):
	var arr = []
	var imag = img.get_image()
	for x in imag.get_width():
		for y in imag.get_height():
			arr.append(imag.get_pixel(x,y))
	var dicts = {}
	for i in arr:
		if !dicts.has(i):
			dicts.set(i,0)
		else:
			dicts.set(i,dicts[i] + 1)
	var most = 0
	var mostUsedColor : Color
	for i in dicts:
		if dicts[i] > most && (i.r + i.g + i.b)/3 > 0.1 && i.a > 0.5:
			most = dicts[i]
			mostUsedColor = i
	if mostUsedColor == null:
		mostUsedColor = Color.WHITE
	mostUsedColor.a = 1.0
	print_rich("[color=" + str(mostUsedColor) + "]The player's most used color is " + str(mostUsedColor) + "!")
	return mostUsedColor

func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	var p : Player = GameManager.myPlayer
	p.changedSkin.connect(changeColor)
	changeColor()

func changeColor():
	var p : Player = GameManager.myPlayer
	if p != null:
		hudText.label_settings.font_color = getMostUsedColor(p.billb.texture)

func _physics_process(delta: float) -> void:
	centerContainer.size = get_viewport().get_visible_rect().size
	centerContainer.size.y *= 1.5
	var p : Player = GameManager.myPlayer
	if p != null:
		hudText2.text = ""
		hudFace.texture = p.billb.texture
		hudText.text = p.displayName
		hudText.text += "\n" + tr("HUD_HP") + ": " + str(p.hp) + "\n"
		hudFace.frame = 0
		if p.ouchTime > 0:
			hudFace.frame = 1
		if p.smirkTime > 0:
			hudFace.frame = 2
		if p.taunting:
			hudFace.frame = 3
		if p.weapon != null:
			hudText2.text += p.weapon.weapon.name + "\n" +  tr("HUD_AMMO")  + ": " + str(p.weapon.ammo) 
		else:
			hudText2.text +=  "\n" + tr("HUD_AMMO") + ": 0"
