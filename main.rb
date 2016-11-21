=begin


実行例

開始:
+---------+
|e G G G  |
|    -    |
|  G G G C|
|         |
|G G G|G  |
|         |
|G G|G G G|
|         |
|G G G e G|
|         |
|G G G|G G|
|         |
|    G G  |
+---------+
怪盗例:
+---------+
|e .←.←.←.|
|  ↓ -   ↑|
|  . .←. .|
|  ↓ ↓ ↑  |
|.←. .|.  |
|↓   ↓ ↑  |
|.→.|. .←.|
|  ↓ ↓   ↑|
|.←. .→C .|
|↓       ↑|
|.→.→.|.→.|
|    ↓ ↑  |
|    .→.  |
+---------+

G = gold
C = cat(1)
. = taken
e = exit

R = ring
c = cat(2)

進める方向 ＝ フェンス( - または | )がない && Gまたはeがある
eに入った時に、すべてのGが取得済みであればOK

=end


class Game
  CAT = 'C'
  TAKEN = '.'
  FENCE_V = '|'
  FENCE_H = '-'
  FENCES = [FENCE_V, FENCE_H]
  EXIT = 'e'
  GOLD = 'G'
  SPACE = ' '
  DIRECTIONS = %i(up down left right)

  attr_reader :pos, :golds, :total_golds, :width, :height, :reach_to_exit

  def initialize(map)
    @map = map.tr("\n", '')
    @width = (map.split[0].size - 1) / 2
    @height = (map.split("\n").size - 1) / 2
    @pos = @map.index(CAT)
    @golds = 0
    @total_golds = @map.count GOLD
    @reach_to_exit = false
  end

  def to_s
    @map.scan(/.{#{@width * 2 + 1}}/).join("\n")
  end

  def up(pos = @pos)
    pos - (@width * 2 + 1)
  end
  def up2(pos = @pos)
    up(up(pos))
  end
  def down(pos = @pos)
    pos + @width * 2 + 1
  end
  def down2(pos = @pos)
    down(down(pos))
  end
  def left(pos = @pos)
    pos - 1
  end
  def left2(pos = @pos)
    pos - 2
  end
  def right(pos = @pos)
    pos + 1
  end
  def right2(pos = @pos)
    pos + 2
  end
  def go!(direction)
    check_direction(direction)

    pos1, pos2, arrow = case direction
      when :up then [up, up2, '↑']
      when :down then [down, down2, '↓']
      when :left then [left, left2, '←']
      when :right then [right, right2, '→']
      else raise
    end
    @map = @map.dup
    @map.tr! CAT, TAKEN
    @map[pos1] = arrow
    @golds += 1 if @map[pos2] == GOLD
    @reach_to_exit = true if @map[pos2] == EXIT
    @map[pos2] = CAT
    @pos = pos2
  end

  def check_direction(direction)
    unless DIRECTIONS.include? direction
      raise 'direction should be one of :up, :down, :left, :right'
    end
  end

  def go?(direction)
    check_direction(direction)
    c1 = at(self.send(direction))
    return false if FENCES.include? c1
    c2 = at(self.send("#{direction}2"))
    c2 == EXIT || c2 == GOLD || (@golds == 0 && c2 == SPACE)
  end

  def at(pos)
    @map[pos]
  end

  def clear?
    @reach_to_exit && @golds == @total_golds
  end

  def solve
    Game::DIRECTIONS.each do |dir|
      if self.go? dir
        new_game = self.dup
        new_game.go! dir
        if new_game.clear?
          puts new_game
          exit
        else
          new_game.solve unless new_game.reach_to_exit
        end
      end
    end
  end

end

# game = Game.new(<<-EOS)
# +-----+
# |  G G|
# |     |
# |e|C|G|
# |     |
# |e  |e|
# +-----+
# EOS

game = Game.new(<<-EOS)
+---------+
|e G G G  |
|    -    |
|  G G G C|
|         |
|G G G|G  |
|         |
|G G|G G G|
|         |
|G G G e G|
|         |
|G G G|G G|
|         |
|    G G  |
+---------+
EOS

puts '開始:'
puts game
puts '怪盗例:'
game.solve
