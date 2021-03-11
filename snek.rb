require 'curses'



class Snake
  
  APPLE = 'o'.ord
  SNAKE = '#'.ord
  SPACE = ' '.ord

  def initialize(window)
    @window = window
    @parts = [[10, 10]]
    @direction = :up
    @running = false
  end

  def run(fps=10)
    @running = true
    spawn_apple
    listen_to_keys
    while @running
      move
      sleep 1.0 / fps
    end
    score
  end

  def listen_to_keys()
    @window.keypad(true)
    Thread.new do
      while @running
        case @window.getch()
        when Curses::KEY_UP    then @direction = :up
        when Curses::KEY_DOWN  then @direction = :down
        when Curses::KEY_LEFT  then @direction = :left
        when Curses::KEY_RIGHT then @direction = :right
        end
      end
    end
  end

  def move()
    x, y = @parts.first
    head = case @direction
    when :up    then [x - 1, y]
    when :down  then [x + 1, y]
    when :left  then [x, y - 1]
    when :right then [x, y + 1]
    end

    @window.setpos(*head)
    case @window.inch  # character under cursor
    when APPLE then spawn_apple
    when SPACE then shorten
    else
      game_over
      return
    end

    grow(head)
    
    @window.refresh
  end
  
  def grow(head)
    @window.setpos(*head)
    @window.addstr(SNAKE.chr)
    @parts.unshift(head)
  end

  def shorten()
    tail = @parts.pop
    @window.setpos(*tail)
    @window.addstr(' ')
  end

  def score()
    @parts.size - 1
  end

  def spawn_apple()
    rand_y = rand(2..(@window.maxy-2))
    rand_x = rand(2..(@window.maxx-2))
    @window.setpos(rand_y, rand_x)
    @window.addstr(APPLE.chr)
  end

  def game_over()
    msg = " Game over! Score: #{score} "
    @window.setpos(@window.maxy / 2, @window.maxx / 2 - msg.size / 2)
    @window.addstr(msg)
    @window.refresh()
    sleep 2
    @running = false
  end

end

Curses.init_screen
Curses.curs_set(0)

begin
  window = Curses.stdscr
  window.box(?|.ord, ?─.ord)
  window.refresh

  snek = Snake.new(window)
  score = snek.run
ensure
  Curses.close_screen
end

puts "Score: #{score}"

