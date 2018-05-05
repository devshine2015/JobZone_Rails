require 'rails_helper'

RSpec.describe "messages/index", type: :view do
  before(:each) do
    assign(:messages, [
      Message.create!(
        :message_body => "MyText",
        :message_type => 2,
        :conversation => nil,
        :user => nil
      ),
      Message.create!(
        :message_body => "MyText",
        :message_type => 2,
        :conversation => nil,
        :user => nil
      )
    ])
  end

  it "renders a list of messages" do
    render
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
