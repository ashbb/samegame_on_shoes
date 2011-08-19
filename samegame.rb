require 'green_shoes'
module SameGame
  W, H = 15, 10
  def init_game_board
    @colors = [hotpink, forestgreen, gold, deepskyblue, white]
    @n, @score = @colors.length, 0
    @msg = caption "SCORE 0", stroke: white, left: 30, top: 15
    button ' reset ' do
      @msg.text = fg("SCORE #{@score = 0}", white)
      mk_cells; mk_groups; show_balls
    end.move 345, 10
  end
  def mk_balls top, left
    mk_shadows top, left
    @balls= Array.new(H){Array.new(W){[]}}
    @balls.each_with_index do |line, y|
      line.each_with_index do |ball, x|
        @colors.each do |color|
          ball << oval(top+x*25, left+y*25, 20, 20, fill: color, hidden: true)
        end
        ball.each do |b|
          b.click{del_balls x, y}; b.hover{shadows :show, x, y}; b.leave{shadows :hide, x, y}
        end
      end
    end
  end
  def mk_cells
    @cells = Array.new(H){Array.new(W){rand @n}}
  end
  def mk_groups
    @groups, @checked = [], []
    @cells.each_with_index do |line, y|
      line.each_with_index do |color, x|
        @group = []
        next unless @cells[y][x]
        next if @groups.flatten(1).include? [x, y]
        ck_cells x, y, x, y
        @groups.push @group if @group.length > 1
      end
    end
    alert(@cells.flatten.-([nil]).empty? ? 'All Clear!' : 'Game Over') if @groups.empty?
  end
  def ck_cells x, y, _x, _y
    tmp = [[x-1, y], [x, y-1], [x+1, y], [x, y+1]].map do |(i, j)|
      next if i < 0 or i >= W or j < 0 or j >= H or (i ==_x and j == _y) or @checked.include?([x, y])
      [i, j] if @cells[y][x] == @cells[j][i]
    end
    tmp.delete nil
    tmp.each{|(i, j)| @checked.push([x, y]); ck_cells i, j, x, y}
    @group.push [x, y] unless @group.include? [x, y]
  end
  def show_balls
    @cells.each_with_index do |line, y|
      line.each_with_index do |color, x|
        @balls[y][x].each &:hide; @balls[y][x][color].show if color
      end
    end
  end
  def del_balls x, y
    @shadows.each{|shadow| shadow.each &:hide}
    group = nil
    @groups.each{|g| group = g if g.include? [x, y]}
    if group
      @score += (group.length - 1) ** 2
      @msg.text = fg("SCORE #{@score}", white)
      group.each{|(x, y)| @cells[y][x] = nil; @balls[y][x].each &:hide}
    end
    timer(0.3){line_up_in_order}
  end
  def line_up_in_order
    count = 0
    W.times do |i|
      tmp = (0...H).to_a.reverse.map{|j| @cells[j][i]}
      tmp.delete nil
      (tmp = Array.new(H){'*'}; count += 1) if tmp.empty?
      H.times{|j| @cells[H-j-1][i] = tmp[j]}
    end
    H.times{|j| @cells[j].delete '*'; count.times{@cells[j].push nil}} if count > 0
    mk_groups; show_balls
  end
  def mk_shadows top, left
    @shadows = Array.new(H){[]}
    H.times do |y|
      W.times do |x|
        @shadows[y][x] = oval top+x*25-2, left+y*25-2, 24, 24, fill: springgreen, hidden: true
      end
    end
  end
  def shadows m, x, y
    group = nil
    @groups.each{|g| group = g if g.include? [x, y]}
    group.each{|(x, y)| eval "@shadows[y][x].#{m}"} if group
  end
end
Shoes.app width: 420, height: 310, title: 'SameGame on Green Shoes v1.0' do
  extend SameGame
  background gray(0.1); nostroke
  init_game_board; mk_balls 25, 50; mk_cells; mk_groups; show_balls
end
