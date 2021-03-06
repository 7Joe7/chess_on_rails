require File.dirname(__FILE__) + '/../spec_helper'

describe Match do

  it 'should know which side and player is next to move' do
    m1 = matches(:paul_vs_dean)
    m1.next_to_move.should == :white
    m1.current_player.should == players(:paul)
  end
      
  it 'should display the lineup as white vs. black' do
    matches(:paul_vs_dean).lineup.should == 'Paul vs. Dean'
    matches(:dean_vs_paul).lineup.should == 'Dean vs. Paul'
  end

  it 'should be startable with one player as white and another as black' do
    m = Match.start( :players => [players(:maria), players(:paul)] )
    m.player2.should == players(:paul)
  end

  it 'should have a name' do
    m = matches(:immortal)
    m.name.should == "The Immortal Match (Anderssen vs. Kieseritzky, 1851)"
  end

  describe 'resignation' do

    it 'should make a match inactive' do
      m1 = matches(:paul_vs_dean)
      m1.resign( players(:paul) )
      m1.should_not be_active
    end

    it 'should make the other guy the winner' do
      m1 = matches(:paul_vs_dean)
      m1.resign( players(:paul) )
      m1.winning_player.should == players(:dean)
    end

  end

  describe "- with FEN changes - " do

    AFTER_E4 = 'RNBQKBNR/PPPP1PPP/4P3/8/8/8/pppppppp/rnbqkbnr b'

    it 'should have next_to_move black if FEN starts black (and even # of moves)' do
      m = Match.new( :start_pos => AFTER_E4, :players => [players(:dean), players(:paul)] )
      m.next_to_move.should == :black
    end

    it 'should have newly retrieved matches current with FEN' do
      m = matches(:e4)
      m.next_to_move.should == :black
    end

    it 'should have next_to_move white if FEN starts black (and odd # of moves)' do
      m = matches(:e4)
      m.next_to_move.should == :black

      m.moves << newm = Move.new( :from_coord => 'e7', :to_coord => 'e5' )
      m.next_to_move.should == :white
    end

    it 'should reflect the piece location FEN indicates, not the initial board' do
      m = matches(:e4)
      m.board['e2'].should be_nil
      m.board['e4'].should_not be_nil
    end
  end

end
  
