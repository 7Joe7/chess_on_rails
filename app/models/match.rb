class Match < ActiveRecord::Base
  
  has_many :gameplays
  has_many :players, :through => :gameplays

  has_many :moves, :order => 'created_at ASC', :after_add => :recalc_board_and_check_for_checkmate


  belongs_to :winning_player, :class_name => 'Player', :foreign_key => 'winning_player'

  named_scope :active,    :conditions => { :active => true }
  named_scope :completed, :conditions => { :active => false }
  
  attr_reader :board
  
  #AR callback - ensures a match object has an initialized board
  def after_find
    init_board
  end

  def initialize( opts={} )
    white = opts.delete(:white) if opts[:white]
    black = opts.delete(:black) if opts[:black]
    super
    save!
    gameplays << Gameplay.new(:player_id => white.id) if white
    gameplays << Gameplay.new(:player_id => black.id, :black => true) if black
  end

  def player1
    @player1 ||= gameplays.white.first.player
  end

  def player2
    @player2 ||= gameplays.black.first.player
  end
  
  def recalc_board_and_check_for_checkmate(last_move)
    # i thought this was being done for me, but just in case...
    raise ActiveRecord::RecordInvalid.new( self ) unless last_move.errors.empty?

    #update internal representation of the board
    @board.play_move! last_move
    
    other_guy = (last_move.side == :black ? :white : :black)

    checkmate_by( last_move.side ) if @board.in_checkmate?( other_guy )
  end
    
  def init_board
    if self[:start_pos].blank?
      @board = Board.new( self, Chess.initial_pieces ) 
    else
      @board = Board.new( self[:start_pos] )
    end
  end

  # for purposes of move validation it's handy to have access to such a variable
  def current_player
    next_to_move == :black ? gameplays.black.first.player : gameplays.white.first.player
  end
  
  def turn_of?( plyr )	
    self.next_to_move == side_of(plyr)
  end

  # as long as the game starts at the beginning, white goes first
  def first_to_move
    return :white if self[:start_pos].blank?
    @first_to_move ||= Board.new( self[:start_pos] ).next_to_move
  end

  # the next_to_move alternates sides each move (technically every half-move)
  def next_to_move
    moves.count.even? ? first_to_move : opp(first_to_move)
  end

  def side_of( plyr ) 
    return :white if plyr == player1
    return :black if plyr == player2
  end

  def opposite_side_of( plyr )
    side_of(plyr) == :white ? :black : :white
  end

  def lineup
    "#{player1.name} vs. #{player2.name}"
  end

  def resign( plyr )
    self.result, self.active = ['Resigned', 0]
    self.winning_player = (plyr == player1) ? player2 : player1
    save!
  end

  def checkmate_by( side )
    self.reload
    self.result, self.active = ['Checkmate', 0]
    self.winning_player = (side == :white ? player1 : player2 )
    save!
  end

  # returns the opposite of a side, or nil
  def opp( s )
    case s
      when :white; :black
      when :black; :white
    end
  end
end
