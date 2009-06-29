require 'edgecase'
require 'greed_game.rb'
class AboutGreed < EdgeCase::Koan
  # We shall contemplate greed by testing a game.
  def test_can_create_game
    game = Greed.new
    assert_equal Greed, game.class  
    assert_equal 2, game.number_of_players
    
    game = Greed.new(3) 
    assert_equal 3,  game.number_of_players          
  end
    
  def test_player_is_not_in_game_if_score_less_than_300
    player = Player.new(1)
    assert_equal false, player.in_game?
    
    player.add_score(200)
    assert_equal false, player.in_game?
  end
  
  def test_player_is_in_game_if_score_greater_than_300
    player = Player.new(2)
    player.add_score(300)
    assert_equal true, player.in_game?
    
    player2 = Player.new(1)
    player2.add_score(400)
    assert_equal true, player2.in_game?
    player2.add_score(100)
    assert_equal true, player2.in_game?
  end
  
  def test_4_can_play
    game = Greed.new(4)
    game.start
    assert_not_equal nil, game.winner
  end
      
end

# EXTRA CREDIT:
#
# Create a program that will play the Greed Game.
# Rules for the game are in GREED_RULES.TXT.
#
# You already have a DiceSet class and score function you can use.
# Write a player class and a Game class to complete the project.  This
# is a free form assignment, so approach it however you desire.
