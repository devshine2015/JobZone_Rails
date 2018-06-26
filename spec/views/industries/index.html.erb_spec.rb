require 'rails_helper'

RSpec.describe "industries/index", type: :view do
  before(:each) do
    assign(:industries, [
      Industry.create!(
        :title => "Title"
      ),
      Industry.create!(
        :title => "Title"
      )
    ])
  end

  it "renders a list of industries" do
    render
    assert_select "tr>td", :text => "Title".to_s, :count => 2
  end
end
