require 'spec_helper'

describe Project do
  let(:project) { FactoryGirl.build(:project) }

  context "validations" do
    it "must have a title" do
      project.title = ''
      project.save
      expect(project).to be_invalid
      expect(project.errors[:title]).not_to be_empty
    end

    it "title must be unique" do
      p = FactoryGirl.create(:project, title: 'My project')
      project.title = p.title
      project.save
      expect(project).to be_invalid
      expect(project.errors[:title]).not_to be_empty
    end
  end
end
