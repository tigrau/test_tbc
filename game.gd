extends Control

signal win
signal defeat

const AMOUNT_COMBATANTS := 4

var pool : Dictionary = {
	"Ivan" : [5,20],
	"Igor" : [4,16],
	"Jhon" : [8,17],
	"Sergei" : [5,18],
	"Iurii" : [6,19],
	"Richard" : [4,20],
	"Alan" : [7,21],
	"Pol" : [4,22],
	"Brandon" : [6,23],
	"Henry" : [5,24],
}

var fight_pool = []
var fight_pool_copy = []
var fight_pool_temp = []
var round_number := 0
var fight_pool_temp_i :int = -1
enum {ENEMY_TEAM, YOUR_TEAM}

@onready var line_edit: LineEdit = $LineEdit

func _ready() -> void:
	pool_check_for_doubles()
	
func pool_check_for_doubles():
	var array = []
	for combatant in pool:
		if pool[combatant] in array:
			print("Some combatants have exactly the same combination of values")
			return
		array.append(pool[combatant])

func inicitate_teams():
	var keys = pool.keys()
	for i in range(AMOUNT_COMBATANTS*2):
		var key = keys.pop_at(randi_range(0,keys.size()-1))
		if i % 2 == 0:
			fight_pool.append([key,pool[key],true])
		else:
			fight_pool.append([key,pool[key],false])

func show_team(team):
	var enemy_pool = []
	var your_pool = []
	for i in range(fight_pool.size()):
		if fight_pool[i][2]:
			your_pool.append(fight_pool[i])
		else:
			enemy_pool.append(fight_pool[i])
	match team:
		0:
			return enemy_pool
		1:
			return your_pool

func add_iniciative():
	for combatant in fight_pool:
		combatant[1][0] = pool[combatant[0]][0]
		combatant[1][0] += randi_range(0,3)

func sort_fight_pool():
	#print(fight_pool)
	fight_pool.sort_custom(sort_ascending)
	#print("ENEMY_TEAM:",show_team(ENEMY_TEAM))
	#print("YOUR_TEAM:",show_team(YOUR_TEAM))
	check_for_coin_flip()


func sort_ascending(a,b):
	if a[1][0] < b[1][0]:
		return true
	return false

func check_for_coin_flip():
	pass
	for i in range(fight_pool.size() - 2):
		if fight_pool[i][1][0] == fight_pool[i+1][1][0]:
			if randi() % 2 == 0:
				var pop = fight_pool.pop_at(i)
				fight_pool.insert(i+1,pop)

func _on_button_pressed() -> void:
	%Button.disabled = true
	inicitate_teams()
	_start_round()

func _start_round():
	add_iniciative()
	sort_fight_pool()
	round_number += 1
	print("Round:" + str(round_number))
	print("______________________________")
	print("ENEMY_TEAM:",show_team(ENEMY_TEAM))
	print("YOUR_TEAM:",show_team(YOUR_TEAM))
	print("______________________________")
	fight_pool_temp = fight_pool.duplicate(true)
	turn()

func turn():
	fight_pool_temp_i += 1
	if fight_pool_temp_i == fight_pool_temp.size():
		fight_pool_temp_i = -1
		_start_round()
		return
	for combatant in fight_pool:
		if fight_pool_temp[fight_pool_temp_i][0] == combatant[0]:
			if fight_pool_temp[fight_pool_temp_i][2]:
				your_turn()
			else:
				enemy_turn()
				turn()
			return
	#_start_round()
	#enemy_turn()
	#print("ENEMY_TEAM:",show_team(ENEMY_TEAM))
	#print("YOUR_TEAM:",show_team(YOUR_TEAM))
	#fight_pool_copy = fight_pool.duplicate(true)

func your_turn():
	print("ENEMY_TEAM: ",show_team(ENEMY_TEAM))
	#print(show_team(ENEMY_TEAM).size())
	print("Which enemy combatant to attack?")
	line_edit.editable = true


func _on_line_edit_text_submitted(new_text: String) -> void:
	if new_text == "":
		print("_______________________________________________")
		print("You have not entered a combatant name to attack.")
		print("ENEMY_TEAM: ",show_team(ENEMY_TEAM))
		return
	for i in fight_pool.size():
		#print("signal")
		if fight_pool[i][0] == new_text and fight_pool[i][2] == true:
			print("Frendly Fire!")
			print("ENEMY_TEAM: ",show_team(ENEMY_TEAM))
			line_edit.clear()
			your_turn()
			return
		if fight_pool[i][0] == new_text:
			fight_pool[i][1][1] -= randi_range(0,10)
			if fight_pool[i][1][1] <= 0:
				if show_team(ENEMY_TEAM).size() == 1:
					win.emit()
				fight_pool.pop_at(i)
				line_edit.clear()
				#line_edit.editable = false
				#your_turn()
				turn()
				return
			turn()
			return
	#your_turn()

func enemy_turn():
	var attack_pool = []
	for i in fight_pool.size() - 1:
		if fight_pool[i][2]:
			attack_pool.append(fight_pool[i])
	var index = randi_range(0,attack_pool.size()-1)
	for i in fight_pool.size():
		if fight_pool[i][0] == attack_pool[index][0]:
			fight_pool[i][1][1] -= randi_range(0,10)
			print("_______________________________")
			print("Your ",fight_pool[i][0]," TAKES DAMAGE")
			print("_______________________________")
			if fight_pool[i][1][1] <= 0:
				if attack_pool.size() == 1:
					defeat.emit()
					return
				fight_pool.pop_at(i)
				#turn()
				#enemy_turn()
				return
			#turn()
			return
	#enemy_turn()

func _on_win() -> void:
	%Button.hide()
	line_edit.hide()
	$Panel.show()


func _on_defeat() -> void:
	%Button.hide()
	line_edit.hide()
	$Panel2.show()
