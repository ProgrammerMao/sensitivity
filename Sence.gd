extends Node3D


var shoot_data = []

@export var Sensitivity_X = 0.5
@export var Sensitivity_Y = 0.5

var sensitivity_value = 50.0

@onready var Player = $Player
@onready var Camera = $Player/Camera

var Mouse_Normal = Vector2(1,1)

func _ready():
	X.value = 50.0
	Y.value = 50.0
	Aensitivity_Group()
	Input.mouse_mode = 2
	
	for i in range(5):
		older_data.push_back(["Null", "0.0"])
	Older_Update()
	
	

func _input(event):
	if Input.mouse_mode == 2:
		if event is InputEventMouseMotion:
			Player.rotate_object_local(Vector3.UP, deg_to_rad(-event.relative.x * Sensitivity_X))
			Player.rotation.y = clamp(Player.rotation.y,deg_to_rad(-90),deg_to_rad(90))			
			Camera.rotation.x -= deg_to_rad(event.relative.y * Sensitivity_Y)
			Camera.rotation.x = clamp(Camera.rotation.x,deg_to_rad(-90),deg_to_rad(90))
			
			
			var relative_normal = (event.relative).normalized() #起始点定位
			if Mouse_Normal.dot(relative_normal) < 0:
				Mouse_Normal = relative_normal
				Target_Distance(false)
		
		if Input.is_action_just_pressed("LeftMouse"):
			var distance = Target_Distance(true)
			if distance <= 1:
				distance = 1 - distance
				$Player/CrossHair/Accuracy.text = str(distance)
				shoot_data.append(Target_Distance(true))
			else:
				$Player/CrossHair/Accuracy.text = "无效"
			
			Accuracy_Count("")
			
			if Auto:
				Shoot()
				
			Target_Position()
		
		
		if Auto:
			if Input.is_action_pressed("All_Up") or Input.is_action_pressed("X_Up") or Input.is_action_pressed("Y_Up"):
				$Control/PanelGroup/AutoGroup/Tolerance.value += 0.1
			elif Input.is_action_pressed("All_Down") or Input.is_action_pressed("X_Down") or Input.is_action_pressed("Y_Down"):
				$Control/PanelGroup/AutoGroup/Tolerance.value -= 0.1
		else:
			if Input.is_action_pressed("All_Up"):
				if TreeGroup.visible:
					Button1.button_pressed = true
					var value = sensitivity_value + sensitivity_distance[number]
					Aensitivity_Change(value)
				else:
					X.value += 0.1
					Y.value += 0.1
			elif Input.is_action_pressed("All_Down"):
				if TreeGroup.visible:
					Button3.button_pressed = true
					var value = sensitivity_value - sensitivity_distance[number]
					Aensitivity_Change(value)
				else:
					X.value -= 0.1
					Y.value -= 0.1
			
			if Input.is_action_pressed("X_Up"):
				if TreeGroup.visible:
					Button1.button_pressed = true
					var value = sensitivity_value + sensitivity_distance[number]
					Aensitivity_Change(value)
				else:
					X.value += 0.1
			elif Input.is_action_pressed("X_Down"):
				if TreeGroup.visible:
					Button3.button_pressed = true
					var value = sensitivity_value - sensitivity_distance[number]
					Aensitivity_Change(value)
				else:
					X.value -= 0.1
			
			if Input.is_action_pressed("Y_Up"):
				if TreeGroup.visible:
					Button1.button_pressed = true
					var value = sensitivity_value + sensitivity_distance[number]
					Aensitivity_Change(value)
				else:
					Y.value += 0.1
			elif Input.is_action_pressed("Y_Down"):
				if TreeGroup.visible:
					Button3.button_pressed = true
					var value = sensitivity_value - sensitivity_distance[number]
					Aensitivity_Change(value)
				else:
					Y.value -= 0.1
			
			if Input.is_action_pressed("Operate_Middle"):
				if TreeGroup.visible:
					Button2.button_pressed = true
					var value = sensitivity_value
					Aensitivity_Change(value)
			
			if Input.is_action_just_pressed("Enter"):
				if not $Control/TreeGroup/Next.disabled:
					_on_next_pressed()
			
			if $Illustrate/Main.visible:
				if Input.is_action_just_pressed("Up"):
					_on_auto_pressed()
				if Input.is_action_just_pressed("Down"):
					_on_auxiliary_pressed()
	
	if Input.is_action_just_pressed("Enter"):
		if $Control/PanelGroup/AutoGroup.visible:
			_on_auto_pressed()
	
	if Input.is_action_just_pressed("Esc"):
		_on_back_ground_pressed()


func _process(delta):
	if Button1.button_pressed or Button2.button_pressed or Button3.button_pressed:
		$Control/TreeGroup/Next.disabled = false
	else:
		$Control/TreeGroup/Next.disabled = true
	
	Camera.fov = FOV.value
	Sensitivity_X = X.value * 0.01
	Sensitivity_Y = Y.value * 0.01


func Target_Position(): #靶标位置
	var rng = RandomNumberGenerator.new()
	
	var x_max = RangeArea.global_position.x + RangeArea.shape.size.x / 2
	var x_min = RangeArea.global_position.x - RangeArea.shape.size.x / 2
	var x = rng.randf_range(x_min, x_max)
	
	var y_max = RangeArea.global_position.y + RangeArea.shape.size.y / 2
	var y_min = RangeArea.global_position.y - RangeArea.shape.size.y / 2
	var y = rng.randf_range(y_min, y_max)
	
	var z_max = RangeArea.global_position.z + RangeArea.shape.size.z / 2
	var z_min = RangeArea.global_position.z - RangeArea.shape.size.z / 2
	var z = rng.randf_range(z_min, z_max)
	
	$Target.position = Vector3(x, y, z)


#面板
@onready var FOV = $Control/FOV

@onready var TreeGroup = $Control/TreeGroup
@onready var PanelGroup = $Control/PanelGroup

@onready var X = $Control/PanelGroup/X
@onready var Y = $Control/PanelGroup/Y

@onready var BackGround = $BackGround

func Change_Panel(panel):
	shoot_data.clear()
	if panel == 0:
		TreeGroup.visible = false
		PanelGroup.visible = true
		$Illustrate/Main.visible = true
		$Illustrate/Auxiliary.visible = false
		Accuracy_Count("Normal")
		
	elif panel == 1:
		TreeGroup.visible = true
		PanelGroup.visible = false
		$Illustrate/Main.visible = false
		$Illustrate/Auxiliary.visible = true
		
		Accuracy_Count("Auto")


func Accuracy_Count(label):
	var num = 0
	for i in shoot_data:
		num += i
	if shoot_data.size() != 0:
		Accuracy.text = str(num / shoot_data.size())
		return num / shoot_data.size()
	else:
		older_data.push_back([label,Accuracy.text])
		Older_Update()
		Accuracy.text = "0.0"

#自动调整
@onready var Auxiliary = $Control/PanelGroup/Button/Auxiliary

@onready var RayCast = $Player/Camera/RayCast
@onready var Target = $Target
@onready var RangeArea = $Static/RangeArea/Range

@onready var Button_Group = $Control/PanelGroup/Button
@onready var AutoGroup = $Control/PanelGroup/AutoGroup

@onready var Accuracy = $Control/Accuracy

var Auto = false

var Move_Normal = Vector3()

var Target_Normal = Vector3()
var Target_Length_X = Vector3()
var Target_Length_Y = Vector3()

var Start_Point = Vector3()

func _on_auto_pressed():
	shoot_data.clear()
	Accuracy_Count("Auto")
	if Auto:
		Auto = false
		X.editable = true
		Y.editable = true
		Auxiliary.disabled = false
		Button_Group.visible = true
		$Illustrate/Main.visible = true
		$Illustrate/Auto.visible = false
		AutoGroup.visible = false
	else:
		Auto = true
		X.editable = false
		Y.editable = false
		$Illustrate/Main.visible = false
		$Illustrate/Auto.visible = true
		Auxiliary.disabled = true
		Button_Group.visible = false
		AutoGroup.visible = true

func Shoot():
	if Aensitivity_Determine(Move_Normal.x, Target_Normal.x):
		X.value = Aensitivity_Adjust(Sensitivity_X, Target_Length_X)
	else:
		X.value = Aensitivity_Adjust(Sensitivity_X, -Target_Length_X)
	if Aensitivity_Determine(Move_Normal.y, Target_Normal.y):
		Y.value = Aensitivity_Adjust(Sensitivity_Y, Target_Length_Y)
	else:
		Y.value = Aensitivity_Adjust(Sensitivity_Y, -Target_Length_Y)

func Aensitivity_Determine(move_normal, target_normal): #灵敏度判断 超出为F
	if move_normal > 0:
		if target_normal > 0:
			return true
		else:
			return false
	else:
		if target_normal < 0:
			return true
		else:
			return false

func Target_Distance(new): #距离
	var point = RayCast.get_collision_point()
	if new:
		$New.global_position = point
		Target_Normal = (Target.global_position - point).normalized()
		Target_Length_X = abs(Target.global_position.x - point.x)
		Target_Length_Y = abs(Target.global_position.y - point.y)
		Move_Normal = (point - Start_Point).normalized()
		return (Target.global_position - point).length()
	else:
		$Old.global_position = point
		Start_Point = point



func Aensitivity_Adjust(vaule, length):
	var tolerance = $Control/PanelGroup/AutoGroup/Tolerance.value
	var adjust = 10
	var aensitivity = length / adjust + vaule * 100
	if aensitivity > sensitivity_value - tolerance and  aensitivity < sensitivity_value + tolerance:
		return aensitivity
	else:
		return vaule

#树杈
var sensitivity_distance = [25.0, 12.5, 6.3, 1.6]

var number = 0

@onready var Button1 = $Control/TreeGroup/Button1
@onready var Button2 = $Control/TreeGroup/Button2
@onready var Button3 = $Control/TreeGroup/Button3

func Aensitivity_Group():
	shoot_data.clear()
	Accuracy_Count(str(sensitivity_value))
	if number < 4:
		Button1.text = str(sensitivity_value + sensitivity_distance[number])
		Button2.text = str(sensitivity_value )
		Button3.text = str(sensitivity_value - sensitivity_distance[number])
	else:
		X.value = sensitivity_value
		Y.value = sensitivity_value
		Change_Panel(0)

func _on_button_1_pressed():
	var value = sensitivity_value + sensitivity_distance[number]
	Aensitivity_Change(value)

func _on_button_2_pressed():
	var value = sensitivity_value
	Aensitivity_Change(value)

func _on_button_3_pressed():
	var value = sensitivity_value - sensitivity_distance[number]
	Aensitivity_Change(value)

func Aensitivity_Change(value):
	X.value = value
	Y.value = value

func _on_next_pressed():
	sensitivity_value = X.value
	
	Button1.button_pressed = false
	Button2.button_pressed = false
	Button3.button_pressed = false
	
	number += 1
	Aensitivity_Group()

func _on_auxiliary_pressed():
	number = 0
	sensitivity_value = 50.0
	Aensitivity_Group()
	Change_Panel(1)


#历史数据
var older_data = []

@onready var OlderData = $OlderData/Group

func Older_Update():
	for i in range(5):
		i = i + 1
		OlderData.get_node(str(i)).get_node("Label").text = older_data[0][0]
		OlderData.get_node(str(i)).text = older_data[0][1]

func _on_back_ground_pressed():
	if Input.mouse_mode == 2:
		BackGround.visible = true
		Input.mouse_mode = 0
	else:
		BackGround.visible = false
		Input.mouse_mode = 2
