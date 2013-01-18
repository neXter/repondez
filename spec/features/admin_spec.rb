require 'spec_helper.rb'

describe "For an administrator" do

  context "The guest list page" do
    before do
      @guest1 = FactoryGirl.create :guest1
      @guest2 = FactoryGirl.create :guest2
      @invite1 = FactoryGirl.create :invitation
      @invite1.guests << @guest1
      visit guests_url
    end

    it "displays a guest that's not assigned to an invitation" do
      page.should have_content @guest2.first_name
    end

    it "displays a guest that is assigned to an invitation" do
      page.should have_content @guest1.first_name
    end

    it "displays a link to create a new guest" do
      page.should have_link_to new_guest_url
    end

    it "displays a selection for each guest to assign an invitation" do
      page.should have_select "guest_#{@guest1.id}_invitation"
    end

    context "when an invitation is selected for a guest" do
      before do
        select @invite1.id, from: "guest_#{@guest2.id}_invitation"
        click_on 'Save'
      end

      it "displays the guest as having that invitation" do
        page.should have_select "guest_#{@guest1.id}_invitation", selected: @invite1.id
      end
    end

  end

  context "The new guest page" do
    before do
      @guest1 = FactoryGirl.create :guest1
      @guest2 = FactoryGirl.create :guest2
      @guest3 = FactoryGirl.build :guest3
      @invite1 = FactoryGirl.create :invitation
      @invite1.guests << @guest1
      @old_size = Invitation.size
      visit new_guest_url
    end

    it "does show guests with an invitation in the dropdown of other guests" do
      page.should have_content @guest1.first_name
    end

    it "does not show guests with no invitation in the dropdown of other guests" do
      page.should_not have_content @guest2.first_name
    end

    context "when the form is filled" do
      before do
        fill_in 'guest[first_name]', with: @guest3.first_name
        fill_in 'guest[last_name]', with: @guest3.last_name
      end

      context "with another guest (invitation) selected" do
        before do
          select @guest1.full_name, from: 'guest[invitation]'
          click_on 'Save'
        end

        it "does not create a new invitation" do
          Invitation.size.should eq @old_size
        end

        it "adds the new guest to the invitation of the other guest" do
          @guest1.invitation.id.should eq @invite1.id
        end
      end

      context "without another invitation selected" do
        before do
          select 'None', from: 'guest[invitation]'
          click_on 'Save'
        end
        
        it "creates a new invitation" do
          Invitation.size.should eq (@old_size + 1)
        end
        
        it "adds the new guest to the invitation" do
          @guest1.invitation.id.should eq Invitation.last.id
        end
      end
    end
  end
end
