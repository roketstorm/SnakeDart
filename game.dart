import 'dart:html';
import 'dart:math';
import 'dart:collection';
import 'dart:async';

const int CELL_SIZE = 10;

CanvasElement canvas;
CanvasRenderingContext2D context;

Keyboard keyboard = Keyboard();

void main() {
  canvas = querySelector('#canvas');
  context = canvas.getContext('2d');
  drawCell(Point(10, 10), 'salmon');

  Game()..run();

  // Snake snake = Snake();
  // clear();
  // snake.update();
}

void drawCell(Point coords, String color) {
  context
    ..fillStyle = color
    ..strokeStyle = 'white';

  final int x = coords.x * CELL_SIZE;
  final int y = coords.y * CELL_SIZE;

  context
    ..fillRect(x, y, CELL_SIZE, CELL_SIZE)
    ..strokeRect(x, y, CELL_SIZE, CELL_SIZE);
}

void clear() {
  context
    ..fillStyle = 'white'
    ..fillRect(0, 0, canvas.width, canvas.height);
}

class Keyboard {
  HashMap<int, num> _keys = HashMap<int, num>();

  Keyboard() {
    window.onKeyDown.listen((event) {
      _keys.putIfAbsent(event.keyCode, () => event.timeStamp);
    });

    window.onKeyUp.listen((event) {
      _keys.remove(event.keyCode);
    });
  }

  bool isPressed(int keyCode) => _keys.containsKey(keyCode);
}

class Snake {
  static const Point LEFT = Point(-1, 0);
  static const Point RIGHT = Point(1, 0);
  static const Point UP = Point(0, -1);
  static const Point DOWN = Point(0, 1);
  static const int START_LENGTH = 6;

  List<Point> _body;
  Point _dir = RIGHT;

  Snake() {
    int i = START_LENGTH - 1;
    _body = List<Point>.generate(START_LENGTH, (index) => Point(i--, 0));
  }

  Point get head => _body.first;

  void _checkInput() {
    if (keyboard.isPressed(KeyCode.LEFT) && _dir != RIGHT) {
      _dir = LEFT;
    } else if (keyboard.isPressed(KeyCode.RIGHT) && _dir != LEFT) {
      _dir = RIGHT;
    } else if (keyboard.isPressed(KeyCode.UP) && _dir != DOWN) {
      _dir = UP;
    } else if (keyboard.isPressed(KeyCode.DOWN) && _dir != UP) {
      _dir = DOWN;
    }
  }

  void grow() {
    _body.insert(0, head + _dir);
  }

  void _move() {
    grow();
    _body.removeLast();
  }

  void _draw() {
    for (Point p in _body) {
      drawCell(p, 'green');
    }
  }

  bool checkForBodyCollision() {
    for (Point p in _body.skip(1)) {
      if (p == head) return true;
    }

    return false;
  }

  void update() {
    _checkInput();
    _move();
    _draw();
  }
}

class Game {
  static const num GAME_SPEED = 50;
  num _lastTimeStamp = 0;

  int _rightEdgeX;
  int _bottomEdgeY;

  Snake _snake;
  Point _food;

  Game() {
    _rightEdgeX = canvas.width ~/ CELL_SIZE;
    _bottomEdgeY = canvas.height ~/ CELL_SIZE;

    init();
  }

  void init() {
    _snake = Snake();
    _food = _randomPoint();
  }

  Point _randomPoint() {
    Random random = Random();
    return Point(random.nextInt(_rightEdgeX), random.nextInt(_bottomEdgeY));
  }

  void _checkForCollisions() {
    if (_snake.head == _food) {
      _snake.grow();
      _food = _randomPoint();
    }

    if (_snake.head.x <= -1 ||
        _snake.head.x >= _rightEdgeX ||
        _snake.head.y <= -1 ||
        _snake.head.y >= _bottomEdgeY) {
      init();
    }
  }

  Future run() async {
    update(await window.animationFrame);
  }

  void update(num delta) {
    final num diff = delta - _lastTimeStamp;

    if (diff > GAME_SPEED) {
      _lastTimeStamp = delta;
      clear();
      drawCell(_food, 'blue');
      _snake.update();
      _checkForCollisions();
    }

    run();
  }
}
