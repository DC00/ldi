-- Weird class names are from picture on Wikipedia under "Least Common Ancestor"
class LightestGreen {};
class LighterGreen inherits LightestGreen {};
class White1 inherits LightestGreen {};
class DarkGreen inherits LighterGreen {};
class X inherits DarkGreen {};
class White2 inherits DarkGreen {};
class Y inherits White2 {};
class Main {main() : Object {0};};
