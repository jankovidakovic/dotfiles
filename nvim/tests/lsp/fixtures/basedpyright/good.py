from os import path


def greet(name: str) -> str:
    return f"Hello, {name}"


result = greet("world")
joined = path.join("a", "b")
