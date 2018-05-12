App.room = App.cable.subscriptions.create "RoomChannel",
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    message = data['message']
    if message
      $('#conversation-'+message.conversation_id).append(
        "<tr class=''>" +
          "<td>"+message.message_body+"</td>" +
          "<td>"+message.message_type+"</td>" +
          "<td>"+message.conversation_id+"</td>" +
          "<td>"+message.user_id+"</td>" +
          "</tr>"
      )
    # Called when there's incoming data on the websocket for this channel

  speak: (message) ->
    @perform 'speak', message: message
