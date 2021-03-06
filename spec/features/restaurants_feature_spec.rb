require 'rails_helper'

feature 'restaurants' do
  before do
    visit '/'
    click_link 'Sign up'
    fill_in 'Email', with: 'dan.blakeman@oxen.com'
    fill_in 'Password', with: 'five_oxes'
    fill_in 'Password confirmation', with: 'five_oxes'
    click_button 'Sign up'
  end

  context 'no restaurants have been added' do
    scenario 'should display a prompt to add a restaurant' do
      visit '/restaurants'
      expect(page).to have_content('No restaurants yet')
      expect(page).to have_link('Add a restaurant')
    end
  end

  context 'restaurants have been added' do
    before do
      Restaurant.create name: 'KFC'
    end

    scenario 'display restaurants' do
      visit '/restaurants'
      expect(page).to have_content 'KFC'
      expect(page).not_to have_content 'No restaurants yet'
    end
  end

  context 'creating restaurants' do
    scenario 'prompts user to fill out'\
    ' a form then displays the new restaurant' do
      visit '/restaurants'
      click_link 'Add a restaurant'
      fill_in 'Name', with: 'KFC'
      click_button 'Create Restaurant'
      expect(page).to have_content('KFC')
      expect(current_path).to eq('/restaurants')
    end

    context 'an invalid restaurant' do
      scenario 'does not let you submit a name that is too short' do
        visit '/restaurants'
        click_link 'Add a restaurant'
        fill_in 'Name', with: 'KF'
        click_button 'Create Restaurant'
        expect(page).not_to have_css('h2', text: 'KF')
        expect(page).to have_content('error')
      end
    end
  end

  context 'viewing restaurants' do
    let!(:kfc) { Restaurant.create(name: 'KFC') }

    scenario 'lets the user view a restaurant' do
      visit '/restaurants'
      click_link 'KFC'
      expect(page).to have_content 'KFC'
      expect(current_path).to eq "/restaurants/#{kfc.id}"
    end
  end

  context 'editing restaurants' do
    before do
      user = User.where(email: 'dan.blakeman@oxen.com').last
      Restaurant.create(name: 'KFC', user_id: user.id)
    end

    scenario 'let a user edit a restaurant' do
      visit '/restaurants'
      click_link 'Edit KFC'
      fill_in 'Name', with: 'Kentucky Fried Chicken'
      click_button 'Update Restaurant'
      expect(page).to have_content 'Kentucky Fried Chicken'
      expect(current_path).to eq '/restaurants'
    end

    scenario 'can\'t edit restaurant which you haven\'t created' do
      Restaurant.create name: 'Makers Diner'
      visit '/restaurants'
      expect(page).not_to have_link 'Edit Makers Diner'
    end

    scenario 'can\'t edit restaurant when signed out' do
      visit '/restaurants'
      click_link 'Sign out'
      expect(page).not_to have_link 'Edit KFC'
    end
  end

  context 'deleting restaurants' do
    before do
      user = User.where(email: 'dan.blakeman@oxen.com').last
      Restaurant.create(name: 'KFC', user_id: user.id)
    end

    scenario 'can\'t remove restaurant which you haven\'t created' do
      Restaurant.create name: 'Makers Diner'
      visit '/restaurants'
      expect(page).not_to have_link 'Delete Makers Diner'
    end

    scenario 'remove the restaurant when a user clicks the delete link' do
      visit '/restaurants'
      click_link 'Delete KFC'
      expect(page).not_to have_content('KFC')
      expect(page).to have_content('Restaurant deleted successfully')
    end

    scenario 'can\'t remove restaurant when signed out' do
      visit '/restaurants'
      click_link 'Sign out'
      expect(page).not_to have_link 'Delete KFC'
    end
  end
end
