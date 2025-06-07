extends Area2D
class_name InteractionArea

@export var action_name: String = "interact"
@export var message_text: String

var interact: Callable = func():
	pass

func _on_body_entered(body: Node2D) -> void:
	InteractionManager.register_area(self)

func _on_body_exited(body: Node2D) -> void:
	InteractionManager.unregister_area(self)

func message(text: String, duration: float = 2.0):
	InteractionManager.show_message(text, duration)
	print("Text got into Interaction Area")
