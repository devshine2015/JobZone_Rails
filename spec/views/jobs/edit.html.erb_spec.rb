require 'rails_helper'

RSpec.describe "jobs/edit", type: :view do
  before(:each) do
    @job = assign(:job, Job.create!(
      :title => "MyString",
      :location => "MyString",
      :status_id => 1,
      :description => "MyText",
      :user => nil,
      :company => nil
    ))
  end

  it "renders the edit job form" do
    render

    assert_select "form[action=?][method=?]", job_path(@job), "post" do

      assert_select "input[name=?]", "job[title]"

      assert_select "input[name=?]", "job[location]"

      assert_select "input[name=?]", "job[status_id]"

      assert_select "textarea[name=?]", "job[description]"

      assert_select "input[name=?]", "job[user_id]"

      assert_select "input[name=?]", "job[company_id]"
    end
  end
end
