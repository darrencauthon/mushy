from sense_hat import SenseHat, ACTION_PRESSED, ACTION_HELD, ACTION_RELEASED
from signal import pause

sense = SenseHat()

def clamp(value, min_value=0, max_value=7):
    print(value)

def pushed_up(event):
    if event.action != ACTION_RELEASED:
        clamp("up")

def pushed_down(event):
    if event.action != ACTION_RELEASED:
        y = clamp("down")

def pushed_left(event):
    if event.action != ACTION_RELEASED:
        x = clamp("left")

def pushed_right(event):
    if event.action != ACTION_RELEASED:
        x = clamp("right")

sense.stick.direction_up = pushed_up
sense.stick.direction_down = pushed_down
sense.stick.direction_left = pushed_left
sense.stick.direction_right = pushed_right
pause()