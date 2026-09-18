## Defines a transition between a parent [State] and one of it's siblings.
class_name StateTransition
extends Node

@export var to_state: State ## [State] to transition to when [member advance_expression] evaluates to true.
@export_multiline var advance_expression: String ## When true, this transition will occur.

@onready var state: State = get_parent() ## The [State] this transition is a child of.

var expression: Expression = Expression.new() ## Expression to evaluate [member advance_expression].

## Checks if condition is met for transition to occur.
func condition_met() -> bool:
	var error = expression.parse(advance_expression)
	if error != OK:
		push_error(expression.get_error_text())
		return false
	var result = expression.execute([], state)
	if expression.has_execute_failed():
		return false
	if not result is bool:
		return false
	return result
