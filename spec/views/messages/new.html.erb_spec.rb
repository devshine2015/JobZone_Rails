require 'rails_helper'

RSpec.describe "messages/new", type: :view do
  before(:each) do
    assign(:message, Message.new(
      :message_body => "MyText",
      :message_type => 1,
      :conversation => nil,
      :user => nil
    ))
  end

  it "renders new message form" do
    render

    assert_select "form[action=?][method=?]", messages_path, "post" do

      assert_select "textarea[name=?]", "message[message_body]"

      assert_select "input[name=?]", "message[message_type]"

      assert_select "input[name=?]", "message[conversation_id]"

      assert_select "input[name=?]", "message[user_id]"
    end
  end
end
