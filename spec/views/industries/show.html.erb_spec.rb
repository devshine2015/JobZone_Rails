require 'rails_helper'

RSpec.describe "industries/show", type: :view do
  before(:each) do
    @industry = assign(:industry, Industry.create!(
      :title => "Title"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Title/)
  end
end
