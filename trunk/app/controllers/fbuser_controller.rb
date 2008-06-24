#todo - haven't found a way to get this fully under test - actual facebook requests i can't simulate as far as i can tell

class FbuserController < ApplicationController	

	before_filter :authenticate_to_facebook

	def index
	end

	def register
		@fb_user = Fbuser.find_by_facebook_user_id( params[:fb_sig_user] )

		@fb_user.name = params[:name] and redirect_to( 'index' ) and return if @fb_user

		#else we don't know them - set them up 
		p = Player.create( :name => params[:name] )
		@fb_user = Fbuser.create( :facebook_user_id => params[:fb_sig_user], :playing_as => p )

		#give them a match with me just to start
		Match.create( :player1 => p, :player2 => Player.find(1) )

		redirect_to( :controller => 'match', :action => 'index' )
	end

private

	def authenticate_to_facebook
		if RAILS_ENV=='test'
			params[:format]='fbml'
			send(:ensure_authenticated_to_facebook) unless params[:fb_sig_user]
		#else
		#	send(:ensure_authenticated_to_facebook)
		end
	end
end

