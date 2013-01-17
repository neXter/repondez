require 'spec_helper'

describe "An Invitation" do
  describe "View page" do
    before do
      @guest1 = FactoryGirl.create :guest1
      @guest2 = FactoryGirl.create :guest2
      @invite1 = FactoryGirl.create :invitation
      @invite1.guests << @guest1 << @guest2
      @invite1.save
      @question1 = FactoryGirl.create :question
      @question2 = FactoryGirl.create :question, label: 'Do you like food?'

      visit invitation_path(@invite1)
    end

    context "for the first guest" do
      it "shows the first question" do
        within :css, ".guest_#{@guest1.id}" do
          page.should have_text @question1.label
        end
      end

      it "shows the second question" do
        within :css, ".guest_#{@guest1.id}" do
          page.should have_text @question2.label
        end
      end
    end

    context "for the second guest" do
      it "shows the first question" do
        within :css, ".guest_#{@guest2.id}" do
          page.should have_text @question1.label
        end
      end

      it "shows the second question" do
        within :css, ".guest_#{@guest2.id}" do
          page.should have_text @question2.label
        end
      end
    end
  end

end