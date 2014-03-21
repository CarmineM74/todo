require 'spec_helper'

describe Task do
  let(:task) { FactoryGirl.build(:task) }

  context "validations" do
    it "must have a name" do
      task.name = ''
      task.save
      expect(task).to be_invalid
      expect(task.errors[:name]).not_to be_empty
    end

    it "name must be unique" do
      t = FactoryGirl.create(:task, name: 'my name')
      task.name = t.name
      task.save
      expect(task).to be_invalid
      expect(task.errors[:name]).not_to be_empty
    end
  end
end
