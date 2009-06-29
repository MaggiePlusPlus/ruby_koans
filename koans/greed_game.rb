#!/usr/bin/env ruby
# -*- ruby -*-

# simulator for greed dice game - by Maggie Longshore

class DiceSet
  def DiceSet.roll(n)
    return (1..n).map { rand(6) + 1 }
  end
end

class Coin
  def Coin.throw
    return :heads unless rand(2) == 1
    return :tails
  end
end

class Player  
  attr_reader :position, :score, :had_final_turn  
  attr_writer :had_final_turn
  
  def initialize(number)
    @position = number    
    @score = 0      
    @had_final_turn = false
    @in_game = false    
  end 
  
  def in_game?
    return @in_game
  end
  
  def roll_again?
    print  "Try for more points?  "
    if Coin.throw == :tails
      puts "No\n"
      return false
    else
      puts "Yes\n"
      return true
    end
  end
  
  def to_s
    "Player #{@position}: "
  end
  
  def <=>(other)
    self.score <=> other.score
  end
  
  def take_turn
    puts "\n#{to_s} starts turn"
    turn = Turn.new 
    bonus_points = 0   
    while turn.not_over?
       turn.go
       if turn.remaining_dice == 0
         puts "scored all 5 dice - take bonus turn..."
         bonus = true
         bonus_points += turn.score_so_far
         turn = Turn.new
       else
         if turn.score_so_far > 0
           puts "turn points: #{turn.score_so_far}   remaining dice: #{turn.remaining_dice}"         
           turn.take_score_and_stop_turn unless roll_again?
         end
       end
    end
    add_score(turn.score_so_far + bonus_points)
    puts "#{to_s} turn over,   turn score: #{turn.score_so_far + bonus_points}    total score: #{@score}\n"   
  end
  
  def add_score(turn_score)
    if @in_game
      @score += turn_score
    else 
      if turn_score >= 300
        @score += turn_score
        @in_game  = true
        puts "!!! #{to_s} has joined the game !!!"
      end
    end
  end
  
  class Turn
    attr_reader :score_so_far, :remaining_dice, :number_dice_scored
    
    def initialize
      @score_so_far = 0
      @remaining_dice = 5
      @number_dice_scored = 0
      @over = false
    end
    
    def take_score_and_stop_turn
      @over = true
    end
    
    def not_over?
      ! @over
    end
    
    def go    
      values = DiceSet.roll(@remaining_dice)
      print "  rolling....      "
      values.each { |die| print "#{die}  "}  
      	print "   :  " 	
      value = score(values)
      if value == 0
        puts " Oops - zero points"
        @score_so_far = 0
        @over=true
      else
        puts " #{value} points"
        @score_so_far += value
      end
    end       
    
    def score(dice)
      if dice.size > 5
        fail "Up to 5 dice only"
      end      
      rolls = [0, 0, 0, 0, 0, 0, 0] 
      dice.each { |die| rolls[die] +=1 }          
      @number_dice_scored = count_number_scored(rolls)
      @remaining_dice -= @number_dice_scored    
      return calculate_score(rolls)
    end
    
    private
      def count_number_scored(rolls)
       count = rolls[1] + rolls[5]
        if rolls[2] >= 3 || rolls[3] >= 3 || rolls[4] >= 3 || rolls[6] >= 3
        	count += 3
        end
        return count
      end
      
      def calculate_score(rolls)
        result = 0
        if rolls[1] >=3
          result += 1000 + (rolls[1] - 3) * 100
        else
           result += rolls[1] * 100
        end    
         
        result += 200 unless rolls[2] < 3
        result += 300 unless rolls[3] < 3
        result += 400 unless rolls[4] < 3
        
        if rolls[5] >=3
          result += 500 + (rolls[5] - 3) * 50
        else
           result += rolls[5] * 50
        end     
        
        result += 600 unless rolls[6] < 3
        return result
      end  
  end
end

class Greed
  attr_reader :number_of_players, :winner 
   
  def initialize(players=2)
    @round = 1
    @start_last_round = false
    @number_of_players = players   
    @entrant = Array.new    
    (1..@number_of_players).each do |number|    
    	@entrant.push(Player.new(number))
    end
  end
  
  def start
    puts "Start game"
    while ! last_round?
      puts "\nStarting round #{@round}"
      do_round
      @round +=1
    end
    puts "Congrats, you pass 3000, everyone else gets one more turn\n"
    do_last_round    
    @winner = @entrant.max
    puts "\n\nWinner is #{@winner.to_s} with #{@winner.score} points!\n\n\n"
  end 
    
  def do_round
    @entrant.each do |player| 
    	  player.take_turn
    	  if player.score >= 3000
    	    player.had_final_turn = true
    	    @start_last_round = true
    	    return
    	  end
     end
  end
  
  def do_last_round 
   while !@entrant[0].had_final_turn
     player = @entrant.shift
     @entrant.push(player)
   end
    turns_left = @number_of_players-1
    (1..turns_left).each do |number|
    	player = @entrant[number]
    	player.take_turn
    end      
  end
  
  def last_round?
    return @start_last_round
  end    
end