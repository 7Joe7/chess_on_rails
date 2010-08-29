// Update 'current status' fields
game_view_model.last_move_id =  <%= last_move ? last_move.id : 'null' %>;
game_view_model.last_chat_id =  <%= last_chat ? last_chat.id : 'null' %>;

game_view_model.your_turn( <%= your_turn %> );
game_view_model.allowed_moves = <%= board.allowed_moves.to_json %>;
game_view_model.last_move     = <%= last_move ? last_move.to_json : 'null' %>;

// Update any moves they haven't seen;
<% match.moves_more_recent_than( params[:last_move_id].to_i ).each do |move| -%>
game_view_model.all_moves.push( <%= move.to_json %> );
<% end -%>

// Update any chats they haven't seen;
<% match.chats_more_recent_than( params[:last_chat_id].to_i ).each do |chat| -%>
game_view_model.all_chats.push( <%= chat.to_json %> );
<% end -%>

