ActiveAdmin.register User do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end

  permit_params :email, :phone, :password, :password_confirmation, :approved

  filter :email_contains
  filter :phone_contains
  filter :last_sign_in_at

  show do
    attributes_table do
      row :email
      row :phone
      row :provider
      row :approved
      row :sign_in_count
      row :last_sign_in_at
      row :created_at
    end
    active_admin_comments
  end

  index do
    id_column
    column :email
    column :phone
    column :provider
    column :approved
    column :sign_in_count
    column :last_sign_in_at
    column :created_at
    actions defaults: true do |user|
      link_to "#{user.approved ? 'Reject' : 'Approve'}",toggle_status_admin_user_path(user), method: :put
    end
  end

  form do |f|
    f.inputs 'User' do
      f.input :email
      f.input :phone
      f.input :password
      f.input :password_confirmation
      f.input :approved
    end
    f.actions
  end

  member_action :toggle_status, method: :put do
    resource.toggle_status!
    redirect_to admin_user_path(resource), notice: "Approved!"
  end

  # actions defaults: true do |user|
  #   link_to 'Approve',approve_admin_user_path(user), method: :put
  # end

end
