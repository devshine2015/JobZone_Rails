require 'rails_helper'

RSpec.describe "jobs/new", type: :view do
  before(:each) do
    assign(:job, Job.new(
      :title => "MyString",
      :location => "MyString",
      :status_id => 1,
      :description => "MyText",
      :user => nil,
      :company => nil
    ))
  end

  it "renders new job form" do
    render

    assert_select "form[action=?][method=?]", jobs_path, "post" do

      assert_select "input[name=?]", "job[title]"

      assert_select "input[name=?]", "job[location]"

      assert_select "input[name=?]", "job[status_id]"

      assert_select "textarea[name=?]", "job[description]"

      assert_select "input[name=?]", "job[user_id]"

      assert_select "input[name=?]", "job[company_id]"
    end
  end
end
