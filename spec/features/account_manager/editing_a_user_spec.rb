require 'spec_helper'

feature 'account manager editing a user' do
  scenario 'changing first name, last name and email of a user of own account' do
    account = create(:account)
    user = create(:user, :account => account, :first_name => 'Bob', :last_name => 'Bobson', :email => 'bob@example.com')

    Dom::Admin::Page.sign_in_as(:account_manager, :account => account)
    visit(admin_user_path(user))
    Dom::Admin::UserPage.first.edit_user_link.click
    Dom::Admin::UserForm.first.submit_with(:first_name => 'John', :last_name => 'Jackson', :email => 'john@example.com')

    expect(Dom::Admin::UserPage.first.first_name).to eq('John')
    expect(Dom::Admin::UserPage.first.last_name).to eq('Jackson')
    expect(Dom::Admin::UserPage.first.email).to eq('john@example.com')
  end
end
